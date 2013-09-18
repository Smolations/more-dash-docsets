require File.join(File.dirname(__FILE__), 'Dash.rb')

dash = Dash.new({
    :name           => 'Puppet',
    :display_name   => 'Puppet 3.2',
    :docs_root      => 'puppetdocs-latest',
    :icon           => File.join('icon-images', 'puppetlabs.png')
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
    entries = $dash.clean_dir_entries(path, [
        'config.ru', 'favicon.ico', 'module_cheat_sheet.pdf', 'puppet_core_types_cheatsheet.pdf',
        'README.txt', 'sitemap.xml', 'images', 'latest', 'images', 'assets', 'fonts'
    ])


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

            # remove google analytics and tracking
            `sed -i '' -e '/<!-- Google analytics -->/,/<!-- End Google analytics -->/d' #{entry_path}`
            `sed -i '' -e '/<!-- BEGIN: MARKETO TRACKING -->/,/<!-- END: MARKETO TRACKING -->/d' #{entry_path}`
        end
    end
end


# kick off the function to make href and src paths relative
puts "Relative-izing src/href attributes and removing analytics..."
dive(dash::docs_root)
puts " \`-Done processing #{$fileCount} files."



# load up guides
puts "Processing guides..."
guides_path = File.join(dash::docs_root, 'guides')
guides      = dash.clean_dir_entries(guides_path)
cnt         = 0

guides.each do |entry|
    entry_path  = File.join(guides_path, entry)
    sql_path    = File.join('guides', entry)

    if !File.directory?(entry_path)
        doc     = $dash.get_noko_doc(sql_path)
        # the split character had to be copied and pasted from one of the docs. it is &#8212;
        name    = doc.at_css('title').content.split('—').shift.strip
        type    = 'Guide'
        if !name.nil?
            cnt = cnt + 1
            $dash.sql_insert(name, type, sql_path)
        end
    end
end
puts " \`- Done processing #{cnt} files."


# the following pages are all versioned. we sync versions here.
refs_version    = 'latest'
# refs_version = '3.2.3'    # if a specific version is desired

# Types
puts "Processing types reference..."
cnt         = 0
refs_page   = 'type.html'
sql_path    = File.join('references', refs_version, refs_page)

docRef      = dash.get_noko_doc(sql_path)
# e.g. <li class="toc-lv2"><a href="#type">
docRef.css('.toc-lv3 a').each do |a|
    cnt     = cnt + 1
    path    = sql_path + a['href']
    name    = path.split('#').pop
    type    = 'Type'
    dash.sql_insert(name, type, path)
end
puts " \`- Done processing #{cnt} Type anchors."


# Functions
puts "Processing Function reference..."
cnt         = 0
refs_page   = 'function.html'
sql_path    = File.join('references', refs_version, refs_page)

docRef    = dash.get_noko_doc(sql_path)
# e.g. <li class="toc-lv2"><a href="#function">
docRef.css('.toc-lv2 a').each do |a|
    cnt   = cnt + 1
    path  = sql_path + a['href']
    name  = path.split('#').pop
    type  = 'Function'
    dash.sql_insert(name, type, path)
end
puts " \`- Done processing #{cnt} Function anchors."


# Metaparameters
puts "Processing Metaparameter reference..."
cnt         = 0
refs_page   = 'metaparameter.html'
sql_path    = File.join('references', refs_version, refs_page)

docRef    = dash.get_noko_doc(sql_path)
# e.g. <li class="toc-lv3"><a href="#metaparam">
docRef.css('.toc-lv3 a').each do |a|
    cnt   = cnt + 1
    path  = sql_path + a['href']
    name  = path.split('#').pop
    type  = 'Parameter'
    dash.sql_insert(name, type, path)
end
puts " \`- Done processing #{cnt} Metaparameter anchors."


# Commands with the `puppet` binary
puts "Processing \`puppet\` binary commands..."
cnt     = 0
entries = dash.clean_dir_entries( File.join(dash::docs_root, 'man') )

# each command has its own html page. notice that this collection of commands
# is simple enough to only use one Dash feature.
entries.each do |entry|
    cnt = cnt + 1
    name = entry.split('.').shift
    type = 'Command'
    path = File.join('man', entry)
    $dash.sql_insert(name, type, path)
end
puts " \`- Done processing #{cnt} Commands."


# Facter: Core Facts
cnt             = 0
refs_version    = '1.7'
refs_page       = 'core_facts.html'
refs_name       = 'facter'
sql_path        = File.join(refs_name, refs_version, refs_page)

docRef          = dash.get_noko_doc(sql_path)
# e.g. <li class="toc-lv2"><a href="#fact">
docRef.css('.toc-lv2 a').each do |a|
    cnt         = cnt + 1
    path        = sql_path + a['href']
    name        = path.split('#').pop
    type        = 'Global'
    dash.sql_insert(name, type, path)
end
puts " \`- Done processing #{cnt} Facter facts."

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
