
classes_list = "index.dsp"

File.open(classes_list, 'r') do |file|
    count   = 0
    queries = []

    file.each_line do |line|

        line = line.chomp
        matches = /^s\d+dsp([a-z]+)01$/.match(line)

        if !matches.nil?
            tag_name = "dsp:#{matches[1]}"
            html_path = "#{line}.html"

            queries << "INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES (\"#{tag_name}\", \"Tag\", \"#{html_path}\");"
        end

        # html_file.close
        count = count + 1

    # /file.each_line
    end

    puts "\nProcessed a total of #{count} lines."
    puts "There are #{queries.length} queries to perform.\n"
    qs = queries.join("\n")
    # puts "\n#{qs}"
    queries.each {|query| `cd DSP.docset/Contents/Resources/; sqlite3 docSet.dsidx '#{query}'`}

    # puts queries.join("\n")

# close classes_list
end
