require File.join(File.dirname(__FILE__), 'Dash.rb')

dash = Dash.new({
    :name           => 'ABS',
    :display_name   => 'Advanced Bash Scripting Guide',
    :docs_root      => 'advanced-bash-scripting-guide',
    :icon           => File.join('icon-images', 'terminal_icon_32x32.png')
})


docIndex = dash.get_noko_doc('index.html')

# dts and dds; the first is the TOC heading
ds = docIndex.css('.TOC > dl').children
ds.shift
ds.each do |d|
    type = 'Guide'
    elementName = d.name

    if elementName == 'dt'
        text = d.text.gsub(/\s{2,}/, ' ')
        # puts text

        sectionParts = text.split(/\.\s/)
        section      = sectionParts[0]

        # first get main parts of the guide (Parts 1-5, Endnotes)
        if section.match(/\d/)
            # puts section
            page = d.at_css('a')['href']
            # puts "#{text}  (#{page})"

            # now we parse the pages linked to on the main page
            docPage = dash.get_noko_doc(page)

            subDs = docPage.css('.TOC > dl').children
            subDs.shift
            subDs.each do |subD|
                # main section (1, 2, etc)
                if subD.name == 'dt'
                    name = subD.text.gsub(/\s{2,}/, ' ').gsub(/"/, "'")

                    if name.match(/^(\d)(?=\.)/)
                        name = subD.text.gsub(/\s{2,}/, ' ').gsub(/"/, "'").gsub(/^(\d)(?=\.)/, '0\1')
                    end

                    path = subD.at_css('a')['href']
                    dash.sql_insert(name, type, path)

                # these entries have subentries (2.1, 2.2, etc)
                elsif subD.name == 'dd'
                    subD.css('dt').each do |subD2|
                        name = subD2.text.gsub(/\s{2,}/, ' ').gsub(/"/, "'")

                        if name.match(/^(\d)(?=\.)/)
                            name = subD2.text.gsub(/\s{2,}/, ' ').gsub(/"/, "'").gsub(/^(\d)(?=\.)/, '0\1')
                        end

                        path = subD2.at_css('a')['href']
                        dash.sql_insert(name, type, path)
                    end
                end
            end

        # then get the Appendixes (A-T)
        elsif section.match(/^[a-z]$/i)
            type = 'Section'
            name = text
            # puts text
            path = d.at_css('a')['href']
            dash.sql_insert(name, type, path)

            sibling = d.next_sibling
            if sibling.name == 'dd'
                subDs = sibling.css('dt')
                subDs.each do |subD|
                    name = subD.text
                    path = subD.at_css('a')['href']
                    dash.sql_insert(name, type, path)
                end
            end

        elsif section.match(/index/i)
            cmds = []
            cmdIndexPath = d.at_css('a')['href']
            docCmdIndex = dash.get_noko_doc(cmdIndexPath)

            type = 'Command'
            docCmdIndex.css('.INDEX > p > .COMMAND').each do |cmd|
                name = cmd.text.gsub(/^\s+|\s+$/, '').gsub(/"/, '""')
                if !cmds.include?(name)
                    # puts name
                    cmds.push(name)
                    cmdId = "dash-cmd#{cmds.length}"
                    path = "#{cmdIndexPath}\##{cmdId}"
                    cmd['id'] = cmdId
                    # cmd.before(dash.get_dash_anchor(docCmdIndex, name, type, cmdId))
                    dash.sql_insert(name, type, path)
                end
            end
            # puts "Commands: #{cmds.length}"

            dash.save_noko_doc(docCmdIndex, cmdIndexPath)
        end
    end
end

# dash.sql_execute({
#     :noop => true,
#     :filter => {
#         # :limit => 5,
#         :type => 'Command',
#         # :name => '36'
#     }
# })
dash.sql_execute

# dash.copy_docs(:noop => true)
dash.copy_docs

puts "\nDone."
