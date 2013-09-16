require File.join(File.dirname(__FILE__), 'Dash.module.rb')

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

dash = Dash.new({
    :name           => 'AWS-CLI',
    :display_name   => 'AWS CLI',
    :docs_root      => File.join('docs.aws.amazon.com', 'cli', 'latest'),
    :icon           => File.join('icon-images', 'aws.png')
})

puts "Beginning the generation of AWS CLI docset..."


# register the Getting Started link as a guide
dash.sql_insert( 'Getting Started', 'Guide', 'tutorial/getting_started.html' )


# most of the top level links we need are in the root index.html file
docIndex = dash.get_noko_doc('index.html')

# while we're here, let's grab the aws command/options
awsCmdFilePath = File.join('reference', 'index.html')
docAwsCmd = dash.get_noko_doc(awsCmdFilePath)

docAwsCmd.css('#options span.pre').each do |span|
    option      = span.content
    newanchorid = option[/\-\-(.*)/, 1]
    newanchor   = dash.get_dash_anchor(docAwsCmd, option, 'Option', newanchorid)
    span.before(newanchor)

    dash.sql_insert( option, 'Option', [awsCmdFilePath, newanchorid].join('#') )
end

# rewrite the file, free up the memory
dash.save_noko_doc(docAwsCmd, awsCmdFilePath)

# insert record for general aws command
dash.sql_insert( 'aws', 'Command', awsCmdFilePath )


# register categories
# e.g. <li class="toctree-l2"><a class="reference internal" href="reference/autoscaling/index.html">autoscaling</a></li>
docIndex.css('li.toctree-l2').each do |li|
    catHref = li.at_css('a')['href']
    catPath = (catHref.split('/') - ['index.html']).join('/')
    cat     = catHref.split('/')[1]
    dash.sql_insert( cat, 'Category', catHref )

    # file containing links to each category
    docCatIndex = dash.get_noko_doc(catHref)

    # dip into each category folder and grab the index.html which has links to all commands
    # e.g. <li class="toctree-l1"><a class="reference internal" href="create-auto-scaling-group.html">create-auto-scaling-group</a></li>
    docCatIndex.css('li.toctree-l1 a').each do |anchor|
        # register command
        cmd     = anchor.content
        cmdPath = [ catPath, '/', cmd, '.html' ].join
        dash.sql_insert( cmd, 'Command', cmdPath )

        docOptions = dash.get_noko_doc(cmdPath)

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
                newanchor   = dash.get_dash_anchor(docOptions, option, 'Option', newanchorid)
                span.before(newanchor)

                dash.sql_insert( option, 'Option', [cmdPath, newanchorid].join('#') )
            end
        end

        # write the new file
        dash.save_noko_doc(docOptions, cmdPath)

        docOptions  = nil
    end

    docCatIndex = nil
end


# dash.sql_execute({
#     :noop => true,
#     :filter => {
#         :limit => 5,
#         :type => 'Class',
#         :name => 'Exception'
#     }
# })
dash.sql_execute

# dash.copy_docs(:noop => true)
dash.copy_docs()

puts "\nDone."
