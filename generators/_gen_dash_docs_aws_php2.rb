require File.join(File.dirname(__FILE__), 'Dash.module.rb')


# first thing, go into resources/style.css and add the following
# at the bottom to remove the left nave pane:
#
#   #left { display: none }
#   #splitter { display: none }
#   #right { margin-left: 20px }

dash = Dash.new({
    :name           => 'AWSPHPSDK2',
    :display_name   => 'AWSPHPSDK2 Test',
    :docs_root      => 'aws-sdk2-php-docs'
})


# $docs_path = File.join(Dash::SRC_DOCS_PATH, 'aws-sdk2-php-docs')


entries = dash.get_clean_docs_entries - [
    '404.html', 'tree.html', 'index.html',
    'elementlist.js', 'resources'
]

# puts entries[0..10]
# exit

$t = 0
queries = []

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
        queries.push(dash.get_sql_insert(name, type, entry))

        # look for exceptions/interfaces (class name ends with Exception/Interface)
        if type == "Class" && /(Exception|Interface)$/.match(name)
            queries.push(dash.get_sql_insert(name, Regexp.last_match(1), entry))
        end

        doc = dash.get_noko_doc(entry)

        # properties
        doc.css('#properties tr').each do |proprow|
            type = 'Property'
            propname = proprow['id']
            proppath = "#{path}\##{propname}"

            newanchor = dash.get_dash_anchor(proprow, propname, type)
            proprow.at_css('td.name var').before(newanchor)

            queries.push(dash.get_sql_insert(propname, type, proppath))
        end

        # methods
        doc.css('.method-container').each do |methwrap|
            type = 'Method'
            methname = methwrap['id']
            methpath = "#{path}\##{methname}"

            newanchor = dash.get_dash_anchor(methwrap, methname, type, '')
            methwrap.before(newanchor)

            queries.push(dash.get_sql_insert(methname, type, methpath))
        end

        dash.save_noko_doc(doc, entry)
        # puts doc.to_html
        # file = File.new(file_name, 'w')
        # file = File.new(path, 'w')
        # file << doc.to_html.gsub('%24', '$')
        # file.close

    end
    $t = $t + 1
end

puts "\nRunning #{queries.length} queries..."
queries.each do |query|
    dash.sql_insert(query)
end

puts "\nQueries/Entries: #{queries.length}/#{$t}"
