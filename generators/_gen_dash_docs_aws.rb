# first thing, go into resources/style.css and add the following
# at the bottom to remove the left nave pane
# #left { display: none }
# #splitter { display: none }
# #right { margin-left: 20px }

require 'rubygems'
require 'nokogiri'


def get_insert(name, type, path)
    return "INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES (\"#{name}\", \"#{type}\", \"#{path}\");"
end
def insert(q)
    `cd AWS-PHP-SDK2.docset/Contents/Resources/; sqlite3 docSet.dsidx '#{q}'; cd ../../..`
end


$docs_path = 'aws-sdk2-php-docs'

entries = Dir.entries($docs_path) - [ '.', '..', '404.html', 'tree.html', 'index.html', 'elementlist.js', 'resources', '.git' ]

$t = 0
$c = 0
paths = []
queries = []
entries.each do |entry|
    matches = /^(\w+)\-([a-z._0-9]+)\.html$/i.match(entry)

    if !matches.nil?
        path = matches[0]
        paths.push(path)
        type = matches[1].capitalize
        fqcn = matches[2]

        # look for class/namespace
        if type == 'Class'
            name = fqcn.split('.').pop
        elsif type == 'Namespace'
            name = fqcn
        end

        # the class/namespace query
        # queries.push("INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES (\"#{name}\", \"#{type}\", \"#{path}\");")
        # queries.push(get_insert(name, type, path))

        # look for exceptions/interfaces (class name ends with Exception/Interface)
        # if type == "Class" && /(Exception|Interface)$/.match(name)
        #     queries.push("INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES (\"#{name}\", \"#{Regexp.last_match(1)}\", \"#{path}\");")
        #     queries.push(get_insert(name, Regexp.last_match(1), path))
        # end

        # if $c == 0 || path.match(/ServiceResponseException/)
            # puts "try nokogiri: #{path}"
            file_name = File.join($docs_path, path)

            file = File.new(file_name, 'r')
            doc = Nokogiri::HTML(file)
            file.close
            doc.encoding = 'UTF-8'

            props_table = doc.css('#properties')

            # properties
            doc.css('#properties tr').each do |proprow|
                propname = proprow['id']
                proppath = "#{path}\##{propname}"

                newanchor = Nokogiri::XML::Node.new('a', proprow)
                newanchor['name'] = "//apple_ref/cpp/Property/#{propname}"
                newanchor['class'] = 'dashAnchor'

                proprow.at_css('td.name var').before(newanchor)

                query = get_insert(propname, 'Property', proppath)
                # puts query
                insert(query)
                $c = $c + 1
            end

            # methods
            doc.css('.method-container').each do |methwrap|
                methname = methwrap['id']
                methpath = "#{path}\##{methname}"

                newanchor = Nokogiri::XML::Node.new('a', methwrap)
                newanchor['name'] = "//apple_ref/cpp/Method/#{methname}"
                newanchor['class'] = 'dashAnchor'

                methwrap.before(newanchor)

                query = get_insert(methname, 'Method', methpath)
                # puts query
                insert(query)
                $c = $c + 1
            end

            # puts doc.to_html
            file = File.new(file_name, 'w')
            # file = File.new(path, 'w')
            file << doc.to_html.gsub('%24', '$')
            file.close
        # end

    end
    $t = $t + 1
end

puts "\nProcessed/Entries: #{$c}/#{$t}"

# diff = entries - paths
# puts "\nDifferences: #{diff.length}"
# puts diff.join("\n")

