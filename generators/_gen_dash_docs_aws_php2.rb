require File.join(File.dirname(__FILE__), 'Dash.module.rb')


# first thing, go into resources/style.css and add the following
# at the bottom to remove the left nave pane:
#
#   #left { display: none }
#   #splitter { display: none }
#   #right { margin-left: 20px }

dash = Dash.new({
    :name           => 'AWS-PHP-SDK2',
    :display_name   => 'AWS PHP SDK2',
    :docs_root      => 'aws-sdk2-php-docs',
    :icon           => File.join('icon-images', 'aws.png')
})


# entries to loop through. all docs are in the root directory.
entries = dash.get_clean_docs_entries - [
    '404.html', 'tree.html', 'index.html',
    'elementlist.js', 'resources'
]


$t = 0
queries = []

puts "\nBeginning the processing of documents..."
entries.each do |entry|
    matches = /^(\w+)\-([a-z._0-9]+)\.html$/i.match(entry)

    if !matches.nil?
        type = matches[1].capitalize
        fqcn = matches[2]

        # look for class/namespace
        if type == 'Class'
            name = fqcn.split('.').pop
        elsif type == 'Namespace'
            name = fqcn
        end

        # the class/namespace query
        dash.sql_insert(name, type, entry)

        # look for exceptions/interfaces (class name ends with Exception/Interface)
        if type == "Class" && /(Exception|Interface)$/.match(name)
            dash.sql_insert(name, Regexp.last_match(1), entry)
        end

        doc = dash.get_noko_doc(entry)

        # properties
        properties = doc.css('#properties tr')
        doc.css('#properties tr').each do |proprow|
            type = 'Property'
            propname = proprow['id']
            proppath = "#{entry}\##{propname}"

            newanchor = dash.get_dash_anchor(proprow, propname, type)
            proprow.at_css('td.name var').before(newanchor)

            dash.sql_insert(propname, type, proppath)
        end

        # methods
        doc.css('.method-container').each do |methwrap|
            type = 'Method'
            methname = methwrap['id']
            methpath = "#{entry}\##{methname}"

            # puts "n: #{methname}, t: #{type}"
            newanchor = dash.get_dash_anchor(methwrap, methname, type, '')
            methwrap.before(newanchor)

            dash.sql_insert(methname, type, methpath)
        end

        dash.save_noko_doc(doc, entry)

    end
    $t = $t + 1
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

puts "\nDone.  Queries/Entries: #{dash.queries.length}/#{$t}"
