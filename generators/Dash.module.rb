require 'rubygems'
require 'nokogiri'


module Dash
    GENERATORS_PATH = File.expand_path(File.dirname(__FILE__))
    DOCSETS_PATH = File.expand_path(File.join(GENERATORS_PATH, '..'))
    SRC_DOCS_PATH = File.join(DOCSETS_PATH, 'src-docs')

    ENTRY_TYPES = [
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

    # file_path is relative to SRC_DOCS_PATH
    def get_doc(file_path)
        full_path = File.join(SRC_DOCS_PATH, file_path)
        if File.exists?(full_path)
            file  = File.new(full_path, 'r')
            doc   = Nokogiri::HTML(file, nil, 'UTF-8')
            file.close
            return doc
        else
            puts "ERROR(Dash::get_doc): Could not find #{full_path}."
        end
        return nil
    end


    def save_doc(doc, file_path)
        full_path = File.join(SRC_DOCS_PATH, file_path)
        if File.exists?(full_path)
            file = File.new(full_path, 'w')
            file << doc.to_xhtml(:encoding => 'US-ASCII')
            file.close
            return true
        else
            puts "ERROR(Dash::save_doc): Could not find #{full_path}."
        end
        return false
    end


    def get_dash_anchor(docReference, name, type, anchor_id)
        if !ENTRY_TYPES.include?(type)
            puts "ERROR(Dash::get_dash_anchor): Invalid type '#{type}'."
            return nil
        end

        a = Nokogiri::XML::Node.new('a', docReference)
        a['name']   = "//apple_ref/cpp/#{type}/#{name}"
        a['class']  = 'dashAnchor'
        a['id']     = anchor_id
        return a
    end


    # availables types
    # Attribute       Binding         Callback        Category        Class
    # Command         Constant        Constructor     Define          Directive
    # Element         Entry           Enum            Error           Event
    # Exception       Field           File            Filter          Framework
    # Function        Global          Guide           Instance        Instruction
    # Interface       Keyword         Library         Literal         Macro
    # Method          Mixin           Module          Namespace       Notation
    # Object          Operator        Option          Package         Parameter
    # Property        Protocol        Record          Sample          Section
    # Service         Struct          Style           Tag             Trait
    # Type            Union           Value           Variable
    def get_sql_insert(name, type, path)
        return "INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES (\"#{name}\", \"#{type}\", \"#{path}\");"
    end

    def sql_insert(docsetName, query)
        rsrcPath = File.join(DOCSETS_PATH, "#{docsetName}.docset", 'Contents', 'Resources')
        if File.exists?(docsetPath)
            `pushd "#{rsrcPath}"; sqlite3 docSet.dsidx '#{q}'; popd`
        else
            puts "ERROR(Dash::sql_insert): Not inserting record. Could not find #{rsrcPath}."
        end
    end
end
