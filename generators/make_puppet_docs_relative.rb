
$docs_path = 'puppetdocs-latest'

entries = Dir.entries($docs_path) - [ '.', '..' ]
$levels = [ '.' ]

def levelup
    $levels.push('/..')
end
def leveldown
    $levels.pop
end

$c = true
def dive(path)
    entries = Dir.entries(path) - [ '.', '..', '.git', 'latest' ]

    entries.each do |entry|
        entry_path = File.join(path, entry)

        if File.directory?(entry_path)
            levelup
            dive(entry_path)
            leveldown

        elsif !entry.match(/\.html$/).nil?
            # if $c
                # fix relative paths for src="" and href="" attributes
                # `sed -i '' -e 's: href="/: href="#{$levels.join}/:' #{entry_path}`
                # `sed -i '' -e "s: href='/: href='#{$levels.join}/:" #{entry_path}`
                # `sed -i '' -e 's: src="/: src="#{$levels.join}/:' #{entry_path}`
                # `sed -i '' -e "s: src='/: src='#{$levels.join}/:" #{entry_path}`

                # remove google analytics and tracking
                `sed -i '' -e '/<!-- Google analytics -->/,/<!-- End Google analytics -->/d' #{entry_path}`
                `sed -i '' -e '/<!-- BEGIN: MARKETO TRACKING -->/,/<!-- END: MARKETO TRACKING -->/d' #{entry_path}`
                # $c = false
            # end
            # puts "in (#{entry_path})  href=\"#{$levels.join}/files/css....."
            # `echo "in (#{entry_path})  href=\"#{$levels.join}/files/css....."`
            # parse html

        end
    end

end


# dive($docs_path)

# load up guides
# guides_path = File.join($docs_path, 'guides')
# guides = Dir.entries(guides_path) - [ '.', '..' ]

# cnt = 0
# guides.each do |entry|
#     entry_path = File.join(guides_path, entry)
#     sqlpath = File.join('guides', entry)
#     if !File.directory?(entry_path)
#         File.open(entry_path) do |file|
#             file.each_line do |line|
#                 title = /<title>(.+)(?= — Documentation)/i.match(line)
#                 if !title.nil?
#                     # puts "INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ('#{title[1]}', 'Guide', '#{sqlpath}');"
#                     query = "INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES (\"#{title[1]}\", \"Guide\", \"#{sqlpath}\");"
#                     `cd Puppet.docset/Contents/Resources/; sqlite3 docSet.dsidx '#{query}'; cd ../../..`
#                 end
#             end
#         end
#         cnt = cnt + 1
#     end
# end
# puts "\n#{cnt} files"
# puts (dirs - ).join("\n")


# Types
# refs_version = '3.2.3'
# refs_page = 'type.html'
# refs_path = File.join($docs_path, 'references', refs_version)
# refs_file = File.join(refs_path, refs_page)
# sqlpath = File.join('references', refs_version, refs_page)

# cnt = 0
# File.open(refs_file) do |file|
#     file.each_line do |line|
#         matches = /<li class="toc\-lv3"><a href="(#([a-z]+))">/.match(line)
#         if !matches.nil?
#             # puts "#{matches[2]}: #{sqlfile}#{matches[1]}"
#             query = "INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES (\"#{matches[2]}\", \"Type\", \"#{sqlpath}#{matches[1]}\");"
#             # puts query
#             `cd Puppet.docset/Contents/Resources/; sqlite3 docSet.dsidx '#{query}'; cd ../../..`
#             cnt = cnt + 1
#         end
#     end
# end
# puts "\n#{cnt} lines"


# Functions
# refs_version = '3.2.3'
# refs_page = 'function.html'
# refs_path = File.join($docs_path, 'references', refs_version)
# refs_file = File.join(refs_path, refs_page)
# sqlpath = File.join('references', refs_version, refs_page)

# cnt = 0
# File.open(refs_file) do |file|
#     file.each_line do |line|
#         matches = /<li class="toc\-lv2"><a href="(#([a-z]+))">/.match(line)
#         if !matches.nil?
#             # puts "#{matches[2]}: #{sqlfile}#{matches[1]}"
#             query = "INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES (\"#{matches[2]}\", \"Function\", \"#{sqlpath}#{matches[1]}\");"
#             # puts query
#             `cd Puppet.docset/Contents/Resources/; sqlite3 docSet.dsidx '#{query}'; cd ../../..`
#             cnt = cnt + 1
#         end
#     end
# end
# puts "\n#{cnt} lines"


# Metaparameters
# refs_version = '3.2.3'
# refs_page = 'metaparameter.html'
# refs_path = File.join($docs_path, 'references', refs_version)
# refs_file = File.join(refs_path, refs_page)
# sqlpath = File.join('references', refs_version, refs_page)

# cnt = 0
# File.open(refs_file) do |file|
#     file.each_line do |line|
#         matches = /<li class="toc\-lv3"><a href="(#([a-z]+))">/.match(line)
#         if !matches.nil?
#             # puts "#{matches[2]}: #{sqlfile}#{matches[1]}"
#             query = "INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES (\"#{matches[2]}\", \"Parameter\", \"#{sqlpath}#{matches[1]}\");"
#             # puts query
#             `cd Puppet.docset/Contents/Resources/; sqlite3 docSet.dsidx '#{query}'; cd ../../..`
#             cnt = cnt + 1
#         end
#     end
# end
# puts "\n#{cnt} lines"


# Commands with the `puppet` binary
# refs_path = File.join($docs_path, 'man')
# entries = Dir.entries(refs_path) - [ '.', '..' ]

# cnt = 0
# entries.each do |entry|
#     tool = entry.split('.').shift
#     refs_file = File.join('man', entry)

#     query = "INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES (\"puppet #{tool}\", \"Command\", \"#{refs_file}\");"
#     # puts query
#     `cd Puppet.docset/Contents/Resources/; sqlite3 docSet.dsidx '#{query}'; cd ../../..`

#     cnt = cnt + 1
# end
# puts "\n#{cnt} lines"



# Facter: Core Facts
refs_version = '1.7'
refs_page = 'core_facts.html'
refs_name = 'facter'

refs_path = File.join($docs_path, refs_name, refs_version)
refs_file = File.join(refs_path, refs_page)
sqlpath   = File.join(refs_name, refs_version, refs_page)

cnt = 0
File.open(refs_file) do |file|
    file.each_line do |line|
        matches = /<li class="toc\-lv2"><a href="(#([a-z]+))">/.match(line)
        if !matches.nil?
            # puts "#{matches[2]}: #{sqlfile}#{matches[1]}"
            if matches[1] != '#summary'
                query = "INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES (\"$#{matches[2]}\", \"Global\", \"#{sqlpath}#{matches[1]}\");"
                # puts query
                `cd Puppet.docset/Contents/Resources/; sqlite3 docSet.dsidx '#{query}'; cd ../../..`
                cnt = cnt + 1
            end
        end
    end
end
puts "\n#{cnt} lines"


# File.open(classes_list, 'r') do |file|
#     count   = 0
#     queries = []

#     file.each_line do |line|

#         line = line.chomp
#         matches = /^s\d+dsp([a-z]+)01$/.match(line)

#         end

#         # html_file.close
#         count = count + 1

#     # /file.each_line
#     end

# # close classes_list
# end
