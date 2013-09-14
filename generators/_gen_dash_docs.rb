require File.join(File.dirname(__FILE__), 'Dash.module.rb')

docs_path = "/Users/cos/Development/workspaces/dash-docs/JSTL1.1.docset/Contents/Resources/Documents"

# classes_list = "#{docs_path}/apiclasses_all.txt"
classes_list = "jstl.index"

log = File.new('missing_paths.log', 'w')


File.open(classes_list, 'r') do |file|
    count   = 0
    pkgs    = []
    queries = []


    file.each_line do |line|
        fields      = []
        methods     = []
        constants   = []


        pieces = line.chomp.split('.')

        class_relative_path = pieces.join(File::SEPARATOR) + '.html'
        class_html_file_path = "Documents/#{class_relative_path}"
        class_name = pieces.pop
        package_name = pieces.join('.')
        package_html_file_path = "Documents/#{pieces.join(File::SEPARATOR)}/package-summary.html"

        # since there are multiple classes within the same package, take care not to add the
        # record twice (even though the query would just be ignored)
        if !pkgs.include?(package_name)
            pkgs << package_name
            queries << "INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ('#{package_name}', 'Package', '#{package_html_file_path}');"
        end
        queries << "INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ('#{class_name}', 'Class', '#{class_html_file_path}');"


        if count == 5
            puts queries.join("\n")
            # puts "\n#{q_package}"
            # puts "#{q_class}"
            # puts "\nPackage(#{package_name})"
            # puts "Package Summary(#{package_html_file_path})"
            # puts "Class HTML(#{class_html_file_path})"
        end

        if (File.exists?(class_html_file_path))
            # now search for identifiers for field variables, methods, etc.
            File.open(class_html_file_path, 'r') do |file2|
                file2.each_line do |line2|
                    if /".*?#{class_relative_path}([^"\(\)]+)((\(\))?)"/ =~ line2
                        hash    = Regexp.last_match(1)
                        parens  = Regexp.last_match(2)

                        if !parens.empty?
                            queries << "INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ('#{class_name}', 'Method', '#{class_html_file_path}');"
                        end
                        if count < 3
                            if !parens.empty?
                                puts 'method!'
                            end
                            puts hash + parens
                        end
                    end
                end
            end

        else
            log << "#{html_file_path}\n"
        end



        # html_file.close
        count = count + 1

    # /file.each_line
    end

    puts "\nProcessed a total of #{count} lines."
    puts "There are #{queries.length} queries to perform."

# close classes_list
end

log.close
