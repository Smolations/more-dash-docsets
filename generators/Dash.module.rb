require 'fileutils'
require 'rubygems'
require 'nokogiri'
require 'git'


class Dash
    # constants
    ROOT_PATH       = File.expand_path(File.join(File.dirname(__FILE__), '..'))
    DOCSETS_PATH    = File.join(ROOT_PATH, 'docsets')
    GENERATORS_PATH = File.join(ROOT_PATH, 'generators')
    RESOURCES_PATH  = File.join(ROOT_PATH, 'resources')
    SRC_DOCS_PATH   = File.join(ROOT_PATH, 'src-docs')
    LOGS_PATH       = File.join(ROOT_PATH, 'logs')

    ENTRY_TYPES     = [
        'Attribute',  'Binding',   'Callback',     'Category',   'Class',
        'Command',    'Constant',  'Constructor',  'Define',     'Directive',
        'Element',    'Entry',     'Enum',         'Error',      'Event',
        'Exception',  'Field',     'File',         'Filter',     'Framework',
        'Function',   'Global',    'Guide',        'Instance',   'Instruction',
        'Interface',  'Keyword',   'Library',      'Literal',    'Macro',
        'Method',     'Mixin',     'Module',       'Namespace',  'Notation',
        'Object',     'Operator',  'Option',       'Package',    'Parameter',
        'Property',   'Protocol',  'Record',       'Sample',     'Section',
        'Service',    'Struct',    'Style',        'Tag',        'Trait',
        'Type',       'Union',     'Value',        'Variable'
    ]

    # instance attributes
    @name
    @display_name
    @docs_root
    @repo
    @docs_dev_branch
    @icon
    @queries

    attr_reader :docset_path, :docset_contents_path, :docset_resources_path, :docset_documents_path, :docs_root, :queries


    ##
     #  Constructor: Dash.new
     #  Takes an +options+ hash with the following keys:
     #
     #  [+:docs_root+]      Relative from the src-docs folder, the location of the docs which will br processed.
     #  [+:name+]           This will become the name of the docset (_:name_.docset).
     #  [+:display_name+]   (optional) This is what displays in Dash. Defaults to :name.
     #
     #  Upon initializing, any previous docset with the same path will be moved to a backup (*.docset.bak)
     #  and the docset will be re-created from scratch.
     ##
    def initialize(options = {})
        # required params
        if options[:docs_root].nil?
            puts "(E) Dash.new: Must construct with hash containing :docs_root"
            return nil
        end
        if options[:name].nil?
            puts "(E) Dash.new: Must construct with hash containing :name"
            return nil
        end

        # optional params
        if options[:display_name].nil?
            options[:display_name] = options[:name]
        end
        if !options[:icon].nil?
            if File.exists?(options[:icon])
                @icon = options[:icon]
            elsif File.exists?( File.join(ROOT_PATH, options[:icon]) )
                @icon = File.join(ROOT_PATH, options[:icon])
            else
                @icon = nil
            end
        end

        @name                   = options[:name]
        @display_name           = options[:display_name]
        @docs_root              = File.join(SRC_DOCS_PATH, options[:docs_root])
        @docset_path            = File.join(DOCSETS_PATH, "#{@name}.docset")
        @docset_contents_path   = File.join(@docset_path, 'Contents')
        @docset_resources_path  = File.join(@docset_contents_path, 'Resources')
        @docset_documents_path  = File.join(@docset_resources_path, 'Documents')
        @docs_dev_branch        = 'dev'
        @queries                = []


        if File.exists?(@docset_path)
            backup_path = "#{@docset_path}.bak"

            puts "Dash.new: Backing up current docset..."
            if File.exists?(backup_path)
                FileUtils.rm_r(backup_path, { :force => true })
            end

            FileUtils.mv(@docset_path, backup_path, { :force => true })
        end

        create_docset

        @repo = get_docs_repo
    end


    ##
    ## :category: CONVENIENCE METHODS
    ##

    # removes unwanted entries for processing (e.g. '.', '..')
    # returns array on success or nil if not a directory
    def clean_dir_entries(dir_path)
        if File.directory?(dir_path)
            return (Dir.entries(dir_path) - [ '.', '..', '.git', '.DS_Store' ])
        end
        return nil
    end

    # calls clean_dir_entries for the @docs_root. useful for looping through
    # the root docs directory in generator scripts.
    def get_clean_docs_entries
        return clean_dir_entries(@docs_root)
    end

    # check if entryName is a Dash-supported Entry Type
    def is_valid_entry(entryName)
        return ENTRY_TYPES.include?(entryName)
    end

    # copies the files in @docs_root into @docset_documents_path.
    def copy_docs(options = {})
        if options[:noop]
            return
        end
        # make sure that, for some reason, @docs_root != ( '/' | '/one-level' )
        if @docs_root.split(File::SEPARATOR).length > 2 && File.directory?(@docset_documents_path)
            puts "Copying documentation into docsets..."

            FileUtils.rm_r( Dir.glob( File.join(@docset_documents_path, '*') ) )
            FileUtils.cp_r( File.join(@docs_root, '.'), @docset_documents_path )

            # remove .git directory if there was one (which there should be)
            git_path = File.join(@docset_documents_path, '.git')
            if File.directory?(git_path)
                FileUtils.rm_r(git_path, :force => true)
            end
        else
            puts "(E) Dash.copy_docs: Failed to copy docs to #{@docset_documents_path}."
        end
    end


    ##
    ## :category: NOKOGIRI-SPECIFIC METHODS
    ##

    # file_path is relative to SRC_DOCS_PATH
    def get_noko_doc(file_path)
        full_path = File.join(@docs_root, file_path)
        # puts "    Getting Nokogiri document: #{full_path}"
        if File.exists?(full_path)
            file  = File.new(full_path, 'r')
            doc   = Nokogiri::HTML(file, nil, 'UTF-8')
            file.close
            return doc
        else
            puts "(E) Dash.get_doc: Could not find #{full_path}."
        end
        return nil
    end

    # file_path is relative to SRC_DOCS_PATH
    def save_noko_doc(doc, file_path)
        full_path = File.join(@docs_root, file_path)
        if File.exists?(full_path)
            file = File.new(full_path, 'w')
            file << doc.to_xhtml(:encoding => 'US-ASCII')
            file.close
            return true
        else
            puts "(E) Dash.save_doc: Could not find #{full_path}."
        end
        return false
    end

    # get Nokogiri doc for new anchor. if +anchor_id+ is not passed, it will default to +name+.
    # if +anchor_id+ is an empty string, no id attribute will be set.
    def get_dash_anchor(docReference, name, type, anchor_id = nil)
        if is_valid_entry(type)
            a = Nokogiri::XML::Node.new('a', docReference)
            a['name'] = "//apple_ref/cpp/#{type}/#{name}"
            a['class'] = 'dashAnchor'

            if anchor_id.nil?
                a['id'] = name
            elsif anchor_id != ''
                a['id'] = anchor_id
            else
                a['id'] = ''
            end

            return a
        else
            puts "(E) Dash.get_dash_anchor: Invalid entry type [#{type}]."
        end

        return nil
    end


    ##
    ## :category: DOCSET-SPECIFIC METHODS
    ##

    # returns the sqlite query for dash entries for given name, [entry] type, path
    def get_sql_insert(name, type, path)
        if !is_valid_entry(type)
            puts "(E) Dash.get_sql_insert: Invalid type '#{type}'."
            return nil
        end
        return "INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES (\"#{name}\", \"#{type}\", \"#{path}\");"
    end

    # runs query in the docset's sqlite database.
    def sql_insert(*args)
        if args.length == 3
            sql_insert(get_sql_insert(*args))

        elsif args.length == 1
            @queries.push(args[0])
            # if File.directory?(@docset_resources_path)
            #     `cd "#{@docset_resources_path}"; sqlite3 docSet.dsidx '#{args[0]}'`
            # else
            #     puts "(E) Dash.sql_insert: Not inserting record. Could not find #{@docset_resources_path}."
            # end
        end
    end

    # Create the sqlite database at the appropriate docset location.
    def setup_sql
        if File.directory?(@docset_resources_path)
            create_table_query = "CREATE TABLE searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT);"
            create_index_query = "CREATE UNIQUE INDEX anchor ON searchIndex (name, type, path);"
            sql_insert(create_table_query)
            sql_insert(create_index_query)
        else
            puts "(E) Dash.setup_sql: Docset Resources path does not exist. The
            sql database was not set up."
        end
    end

    # execute sql statements in the +@queries+ array
    def sql_execute(options = {})
        if @queries.length > 0
            do_queries = true
            queries = @queries.clone

            if options.length
                if options[:noop] == true
                    do_queries = false
                    queries.slice!(0..1)
                    puts "Total of #{queries.length} queries."
                    if options[:filter].is_a?(Hash)
                        filters = options[:filter]
                        if filters[:type]
                            puts "Filtering by type: #{filters[:type]}"
                            patt = Regexp.new(', "' + filters[:type] + '",', Regexp::IGNORECASE)
                            queries.length && queries.map! {|query| query.match(patt) ? query : nil }
                        end
                        queries.compact!
                        if filters[:name]
                            puts "Filtering by name: #{filters[:name]}"
                            patt = Regexp.new('\("[^"]*' + filters[:name] + '[^"]*",', Regexp::IGNORECASE | Regexp::EXTENDED)
                            queries.length && queries.map! {|query| query.match(patt) ? query : nil }
                        end
                        queries.compact!
                        if filters[:limit]
                            puts "Limiting results to: #{filters[:limit]}"
                            start = 0
                            finish = start + filters[:limit].to_i - 1
                            range = start..finish
                            queries = queries[range]
                        end
                        queries.compact!
                    end
                    hr = '-' * 50
                    puts "\n#{hr}"
                    puts 'Staged SQL statements:'
                    puts hr
                    puts queries.join("\n")
                    puts hr
                end
            end

            if do_queries
                puts "Executing #{queries.length} queries..."
                if File.directory?(@docset_resources_path)
                    query_file_path = File.join(RESOURCES_PATH, 'sqlite3.queries')
                    file = File.new(query_file_path, 'w')
                    file << @queries.join("\n")
                    file.close

                    `cd "#{@docset_resources_path}"; sqlite3 docSet.dsidx < '#{query_file_path}'`

                else
                    puts "(E) Dash.sql_execute: Not executing query. Could not find #{@docset_resources_path}."
                end
            end

        end
    end

    # copies the plist template into the appropriate docset location
    def copy_plist
        if File.directory?(@docset_contents_path)
            plist_src_path = File.join(RESOURCES_PATH, 'Info.plist')
            plist_dest_path = File.join(@docset_contents_path,  'Info.plist')

            if File.exists?(plist_src_path)
                FileUtils.cp(plist_src_path, plist_dest_path)
                `sed -i '' "s/displayName/#{@display_name}/g" "#{plist_dest_path}"`

            else
                puts "(E) Dash.copy_plist: Info.plist template does not exist. The
                .plist file was not copied."
            end

        else
            puts "(E) Dash.copy_plist: Docset Contents path does not exist. The
            .plist file was not copied."
        end
    end

    # copies a user-supplied icon into the appropriate docset location
    def copy_icon
        if !@icon.nil?
            if File.exists?(@icon) && @icon.match(/\.png$/)
                FileUtils.cp(@icon, File.join(@docset_path, 'icon.png'))
            else
                puts "(E) Dash.copy_icon: Bad (not PNG) or missing filename given: #{@icon}"
            end

        else
            puts "(E) Dash.copy_icon: No icon to copy."
        end
    end

    # creates the docset hierarchy, the docset .plist, and initializes the database.
    def create_docset
        if !File.exists?(@docset_path)
            puts "Dash.create_docset: Creating docset directory structure #{@docset_documents_path}..."
            FileUtils.mkdir_p(@docset_documents_path)

            puts "Dash.create_docset: Copying .plist file..."
            copy_plist

            if !@icon.nil?
                puts "Dash.create_docset: Copying icon image..."
                copy_icon
            end

            puts "Dash.create_docset: Setting up database..."
            setup_sql

            puts "Dash.create_docset: Docset set-up complete!"
        else
            puts "(W) Dash.create_docset: Docset path already exists. Skipping..."
        end
    end


    ##
    ## :category: MISC METHODS
    ##

    # this method ensures that a git repo exists for the docs_root and that the master
    # branch contains the original import, and changes go on a dev branch with the
    # name @docs_dev_branch.
    def get_docs_repo
        repo = nil

        if File.directory?(@docs_root)
            begin
                repo = Git::open(@docs_root)
                # puts "Resetting working tree..."
                repo.reset_hard

                branch = repo.current_branch
                patt = Regexp.new(@docs_dev_branch)
                if !branch.match(patt)
                    puts "Checking out #{@docs_dev_branch} branch..."
                    repo.branch(@docs_dev_branch).checkout
                end

            rescue ArgumentError => arg_err
                puts "Create repo at #{@docs_root} (y/n)? "
                yn = gets

                if yn.match(/^\w*y(es)?\w*$/i)
                    # initialize repo
                    repo = Git::init(@docs_root)
                    # add all files
                    repo.add( :all => true )
                    repo.commit('(master) initial import from Dash generator')
                    repo.branch(@docs_dev_branch).checkout
                else
                    puts "Not creating docs repo..."
                end
            end

        end

        return repo
    end

end
