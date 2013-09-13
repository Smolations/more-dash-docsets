require 'rubygems'
require 'nokogiri'

$docs_path = File.join('docs.aws.amazon.com', 'cli', 'latest')

# directions below are relative to $docs_path
    # had to download jquery 1.9.1, even though the link is also broken on the site
        # named _static/jquery-1.9.1.min.js.html

    # go into _static/bootstrap.min.css and add the following
        # /* Added for Dash */
        # .navbar.navbar-fixed-top {
        #     display: none;
        # }

    # go into _static/guzzle.css and add the following at the bottom:
        # /* Added for Dash */
        # .sphinxsidebar {
        #   display: none;
        # }
        # .body {
        #   float: none;
        #   width: auto;
        # }

# convenience methods for generating inserts and actually inserting
def get_insert(name, type, path)
    return "INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES (\"#{name}\", \"#{type}\", \"#{path}\");"
end
def insert(q)
    `cd AWS-CLI.docset/Contents/Resources/; sqlite3 docSet.dsidx '#{q}'; cd ../../..`
end

# this is done at least twice, so it'll get its own method
def get_new_anchor(docReference, name, type, anchor_id)
    newanchor = Nokogiri::XML::Node.new('a', docReference)
    newanchor['name']   = "//apple_ref/cpp/#{type}/#{name}"
    newanchor['class']  = 'dashAnchor'
    newanchor['id']     = anchor_id
    return newanchor
end


# register the Getting Started link as a guide
puts get_insert('Getting Started', 'Guide', 'tutorial/getting_started.html')
insert(get_insert('Getting Started', 'Guide', 'tutorial/getting_started.html'))


# most of the top level links we need are in the root index.html file
$index_path = File.join($docs_path, 'index.html')
indexFile   = File.new($index_path, 'r')
docIndex    = Nokogiri::HTML(indexFile, nil, 'UTF-8')
indexFile.close

# while we're here, let's grab the aws command/options
awsCmdFilePath  = File.join('reference', 'index.html')
awsCmdFile      = File.new(awsCmdFilePath, 'r')
docAwsCmd       = Nokogiri::HTML(awsCmdFile, nil, 'UTF-8')
awsCmdFile.close

docAwsCmd.css('#options span.pre').each do |span|
    option      = span.content
    newanchorid = option[/\-\-(.*)/, 1]
    newanchor   = get_new_anchor(docAwsCmd, option, 'Option', newanchorid)
    span.before(newanchor)

    puts get_insert(option, 'Option', [awsCmdFilePath, newanchorid].join('#'))
    insert(get_insert(option, 'Option', [awsCmdFilePath, newanchorid].join('#')))
end

# rewrite the file, free up the memory
awsCmdFile = File.new(awsCmdFilePath, 'w')
awsCmdFile << docAwsCmd.to_xhtml( :encoding => 'US-ASCII' )
awsCmdFile.close
docAwsCmd = nil

# insert record
puts get_insert('aws', 'Command', awsCmdFilePath)
insert(get_insert('aws', 'Command', awsCmdFilePath))

# register categories
# e.g. <li class="toctree-l2"><a class="reference internal" href="reference/autoscaling/index.html">autoscaling</a></li>
docIndex.css('li.toctree-l2').each do |li|
    catHref = li.at_css('a')['href']
    catPath = (catHref.split('/') - ['index.html']).join('/')
    cat     = catHref.split('/')[1]
    puts get_insert(cat, 'Category', catHref)
    insert(get_insert(cat, 'Category', catHref))

    # dip into each category folder and grab the index.html which has links to all commands
    catIndexPath    = File.join($docs_path, catHref)
    catIndexFile    = File.new(catIndexPath, 'r')
    docCatIndex     = Nokogiri::HTML(catIndexFile, nil, 'UTF-8')
    catIndexFile.close

    # e.g. <li class="toctree-l1"><a class="reference internal" href="create-auto-scaling-group.html">create-auto-scaling-group</a></li>
    docCatIndex.css('li.toctree-l1 a').each do |anchor|
        # register command
        cmd     = anchor.content
        cmdPath = [ catPath, '/', cmd, '.html' ].join
        puts get_insert(cmd, 'Command', cmdPath)
        insert(get_insert(cmd, 'Command', cmdPath))

        optionsFilePath = File.join($docs_path, cmdPath)
        optionsFile     = File.new(optionsFilePath, 'r')
        docOptions      = Nokogiri::HTML(optionsFile, nil, 'UTF-8')
        optionsFile.close

        # insert option anchors and catalog options
        # e.g.
        # <div class="section" id="options">
        # <h2>Options<a class="headerlink" href="#options" title="Permalink to this headline">¶</a></h2>
        # <p><tt class="docutils literal"><span class="pre">--auto-scaling-group-name</span></tt> (string)</p>
        docOptions.css('#options span.pre').each do |span|
            option = span.content

            if option.match(/^\-\-/)
                # insert right before span.pre
                newanchorid = option[/\-\-(.*)/, 1]
                newanchor   = get_new_anchor(docOptions, option, 'Option', newanchorid)
                span.before(newanchor)

                puts get_insert(option, 'Option', [cmdPath, newanchorid].join('#'))
                insert(get_insert(option, 'Option', [cmdPath, newanchorid].join('#')))
            end
        end

        # write the new file
        puts "Writing file: #{optionsFilePath}"
        optionsFile = File.new(optionsFilePath, 'w')
        optionsFile << docOptions.to_xhtml( :encoding => 'US-ASCII' )
        optionsFile.close

        docOptions  = nil
    end

    docCatIndex = nil
end
