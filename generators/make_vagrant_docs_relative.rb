
$docs_path = 'vagrant-docs'

entries = Dir.entries($docs_path) - [ '.', '..' ]
$levels = [ '.' ]

def levelup
    $levels.push('/..')
end
def leveldown
    $levels.pop
end

$c = 0
def dive(path)
    entries = Dir.entries(path) - [ '.', '..' ]

    entries.each do |entry|
        entry_path = File.join(path, entry)

        if File.directory?(entry_path)
            levelup
            dive(entry_path)
            leveldown

        elsif !entry.match(/\.html$/).nil?
            # if $c < 2
            #     puts entry_path
                # fix relative paths for src="" and href="" attributes
                `sed -E -i '' -e 's; href="/([a-z]); href="#{$levels.join}/\\1;g' #{entry_path}`
                `sed -E -i '' -e "s: href='/([a-z]): href='#{$levels.join}/\\1:g" #{entry_path}`
                `sed -E -i '' -e 's: src="/([a-z]): src="#{$levels.join}/\\1:g' #{entry_path}`
                `sed -E -i '' -e "s: src='/([a-z]): src='#{$levels.join}/\\1:g" #{entry_path}`

                # remove google analytics and tracking
                # `sed -i '' -e '/<!-- Google analytics -->/,/<!-- End Google analytics -->/d' #{entry_path}`
                # `sed -i '' -e '/<!-- BEGIN: MARKETO TRACKING -->/,/<!-- END: MARKETO TRACKING -->/d' #{entry_path}`
                $c = $c + 1
            # end
            # puts "in (#{entry_path})  href=\"#{$levels.join}/files/css....."
            # parse html

        end
    end

end


# dive($docs_path)
# puts "#{$c} files"


# CLI commands
# refs_path = File.join($docs_path, 'v2', 'cli')
# entries = Dir.entries(refs_path) - [ '.', '..' ]

# cnt = 0
# entries.each do |entry|
#     tool = entry.split('.').shift
#     refs_file = File.join('v2', 'cli', entry)

#     query = "INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES (\"vagrant #{tool}\", \"Command\", \"#{refs_file}\");"
#     # puts query
#     `cd Vagrant.docset/Contents/Resources/; sqlite3 docSet.dsidx '#{query}'; cd ../../..`

#     cnt = cnt + 1
# end
# puts "\n#{cnt} lines"



# load up guides
    # guides_path = File.join($docs_path, 'v2')
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
# i just did it manually...
# INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ("Overview", "Guide", "v2/index.html");
# INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ("Boxes", "Guide", "v2/boxes.html");
# INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ("Command-Line Interface", "Guide", "v2/cli/index.html");
# INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ("Getting Started", "Guide", "v2/getting-started/index.html");
# INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ("Installation", "Guide", "v2/installation/index.html");
# INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ("Multi-Machine", "Guide", "v2/multi-machine/index.html");
# INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ("Networking", "Guide", "v2/networking/index.html");
# INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ("Plugins", "Guide", "v2/plugins/index.html");
# INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ("Providers", "Guide", "v2/providers/index.html");
# INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ("Provisioning", "Guide", "v2/provisioning/index.html");
# INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ("Synced Folders", "Guide", "v2/synced-folders/index.html");
# INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ("Vagrantfile", "Guide", "v2/vagrantfile/index.html");
# INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ("Virtualbox", "Guide", "v2/virtualbox/index.html");
# INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ("VMware", "Guide", "v2/vmware/index.html");
# INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ("Why Vagrant?", "Guide", "v2/why-vagrant/index.html");
# INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ("Debugging", "Guide", "v2/debugging.html");
