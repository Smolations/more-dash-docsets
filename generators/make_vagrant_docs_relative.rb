require File.join(File.dirname(__FILE__), 'Dash.rb')

dash = Dash.new({
    :name           => 'Vagrant',
    :display_name   => 'Vagrant 2',
    :docs_root      => 'vagrant-docs',
    :icon           => File.join('icon-images', 'vagrant-logo.small.png')
})
# so dive can get at it recursively..
$dash = dash


# this is how we'll keep track of how deep in the directory structure we are as we make paths
# relative. this array is joined with the system file separator and prepended to absolute paths.
$levels = [ '.' ]

# shortcut methods to increase/decrease levels.
def level_up
    $levels.push('/..')
end
def level_down
    $levels.pop
end

$fileCount = 0
def dive(path)
    # puts "#{path}"
    entries = $dash.clean_dir_entries(path, ['images', 'javascripts', 'stylesheets'])

    entries.each do |entry|
        entry_path = File.join(path, entry)

        # if we're looking at a directory and not a file [to parse], increase the directory
        # depth, pass the path to this function, then decrease the level back to where it was.
        if File.directory?(entry_path)
            level_up
            dive(entry_path)
            level_down

        # now that we know it's a file, let's get into it.
        elsif !entry.match(/\.html$/).nil?
            $fileCount = $fileCount + 1
            doc = $dash.get_noko_doc(entry_path)
            doc.css('[href]').each {|element| element['href'].match(/^\//) && element['href'] = $levels.join + element['href'] }
            doc.css('[src]').each {|element| element['src'].match(/^\//) && element['src'] = $levels.join + element['src'] }
            $dash.save_noko_doc(doc, entry_path)
        end
    end
end

# kick off the function to make href and src paths relative
puts "Relative-izing src/href attributes..."
dive(dash::docs_root)
puts " \`-Done processing #{$fileCount} files."


# CLI commands
puts "Processing commands..."
cnt         = 0
refs_path   = File.join(dash::docs_root, 'v2', 'cli')
entries     = dash.clean_dir_entries(refs_path)

entries.each do |entry|
    cnt  = cnt + 1
    name = 'vagrant ' + entry.split('.').shift
    type = 'Command'
    path = File.join('v2', 'cli', entry)
    dash.sql_insert(name, type, path)
end
puts " \`- Done processing #{cnt} files."


# load up guides (i just did it manually...it was easier)
dash.sql_insert("Overview",                 "Guide", "v2/index.html");
dash.sql_insert("Boxes",                    "Guide", "v2/boxes.html");
dash.sql_insert("Command-Line Interface",   "Guide", "v2/cli/index.html");
dash.sql_insert("Getting Started",          "Guide", "v2/getting-started/index.html");
dash.sql_insert("Installation",             "Guide", "v2/installation/index.html");
dash.sql_insert("Multi-Machine",            "Guide", "v2/multi-machine/index.html");
dash.sql_insert("Networking",               "Guide", "v2/networking/index.html");
dash.sql_insert("Plugins",                  "Guide", "v2/plugins/index.html");
dash.sql_insert("Providers",                "Guide", "v2/providers/index.html");
dash.sql_insert("Provisioning",             "Guide", "v2/provisioning/index.html");
dash.sql_insert("Synced Folders",           "Guide", "v2/synced-folders/index.html");
dash.sql_insert("Vagrantfile",              "Guide", "v2/vagrantfile/index.html");
dash.sql_insert("Virtualbox",               "Guide", "v2/virtualbox/index.html");
dash.sql_insert("VMware",                   "Guide", "v2/vmware/index.html");
dash.sql_insert("Why Vagrant?",             "Guide", "v2/why-vagrant/index.html");
dash.sql_insert("Debugging",                "Guide", "v2/debugging.html");


# dash.sql_execute({
#     :noop => true,
#     :filter => {
#         :limit => 5,
#         :type => 'Guide',
#         :name => 'Exception'
#     }
# })
dash.sql_execute

dash.copy_docs()

puts "\nDone."
