require File.join(File.dirname(__FILE__), 'Dash.rb')

dash = Dash.new({
    :name           => 'JSTL 1.1',
    :docs_root      => 'jstl-docs',
    :index_page     => 'overview-summary.html',
    :icon           => File.join('icon-images', 'icon_oracle.png')
})


dash.get_clean_docs_entries.each do |entry|
    abs_path = File.join(dash::docs_root, entry)

    if File.directory?(abs_path)

        dash.clean_dir_entries(abs_path).each do |html|
            name = nil
            type = nil
            path = File.join(entry, html)

            # get the landing page for each tag type
            if /tld\-/.match(html)
                if html == 'tld-summary.html'
                    name = entry
                    type = 'Library'

                else
                    # skip tld-frame.html
                    next
                end

            else
                #functions
                if entry == 'fn'
                    if !/\.fn\./.match(html)
                        # for some reason extra function html pages exist, but they are 404s
                        next

                    else
                        docFn = dash.get_noko_doc(path)
                        code = docFn.at_css('code:first-of-type')
                        # puts code.text
                        matches = /[a-z]+\([^\)]+\)/i.match(code.text)
                        if matches
                            name = entry + ':' + matches[0].gsub(/java\.lang\./, '')
                            type = 'Function'
                        end
                    end

                # regular entry
                else
                    name = entry + ':' + html.split('.').shift
                    type = 'Tag'
                end
            end

            if name && type
                dash.sql_insert(name, type, path)
            end
        end

    end
end


# dash.sql_execute({
#     :noop => true,
    # :filter => {
    #     :limit => 5,
    #     :type => 'Guide',
    #     :name => '\s5\.'
    # }
# })
dash.sql_execute

dash.copy_docs

puts "\nAll Done!"
