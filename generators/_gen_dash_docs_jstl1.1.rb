
classes_list = "index.jstl"

File.open(classes_list, 'r') do |file|
    count   = 0
    queries = []

    file.each_line do |line|

        full_element_name = line.chomp
        pieces = full_element_name.split(':')

        pre_element_name = pieces[0]
        pre_element_html_file_path = "#{pre_element_name}/tld-summary.html"
        sub_element_name = pieces[1]
        sub_element_html_file_path = "#{pre_element_name}/#{sub_element_name}.html"

        # since there are multiple classes within the same package, take care not to add the
        # record twice (even though the query would just be ignored)
        queries << "INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES (\"#{pre_element_name}\", \"Library\", \"#{pre_element_html_file_path}\");"
        queries << "INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES (\"#{pre_element_name}:#{sub_element_name}\", \"Tag\", \"#{sub_element_html_file_path}\");"


        # html_file.close
        count = count + 1

    # /file.each_line
    end

    puts "\nProcessed a total of #{count} lines."
    puts "There are #{queries.length} queries to perform.\n"

    queries.each {|query| `cd JSTL1.1.docset/Contents/Resources/; sqlite3 docSet.dsidx '#{query}'`}

    # puts queries.join("\n")

# close classes_list
end
