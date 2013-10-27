require File.join(File.dirname(__FILE__), 'Dash.rb')

dash = Dash.new({
    :name           => 'Chrome Developer Tools',
    :docs_root      => 'chrome-developer-tools',
    :icon           => File.join('icon-images', 'chrome_dev_32x32.png')
})
$dash = dash

docs_root  = File.join(dash::docs_root, 'docs')
index_page = File.join(dash::docs_root, 'index.html')
file_list  = [ index_page ] + dash.dir_recurse_list(docs_root, 'files')


def get_toc(ul, container = [], anchor_selector = '> a')
    if ul.name != 'ul' && ul.name != 'ol'
        return nil
    end

    cnt = 1

    ul.css('> li').each do |li|
        name_elem  = li.at_css(anchor_selector)
        sub_ul     = li.at_css('> ul')
        if !sub_ul
            sub_ul     = li.at_css('> ol')
        end

        if name_elem
            name   = name_elem.text.strip
            subset = (sub_ul) ? get_toc(sub_ul) : []
            container.push( $dash.get_toc_obj(name, name_elem, subset) )
            cnt    = cnt + 1
        end
    end

    return container
end

$toc = []
file_list.each do |entry|
    if /\.html$/.match(entry)
        docHtml = dash.get_noko_doc(entry)

        # fix path for a stylesheet which doesnt specify domain
        link = docHtml.at_css('#screen-foot')
        if link
            # puts link.inspect
            link['data-href'] = 'https://developers.google.com' + link['data-href']
        end

        # remove sidebar and re-style dor dash window
        sidebar    = docHtml.at_css('#gc-sidebar')
        gc_content = docHtml.at_css('#gc-content')
        if gc_content
            gc_content['class'] = ''
            gc_content['style'] = 'margin-left: auto;'
        end

        # use the sidebar to get TOC entries
        if entry == index_page
            $toc    = get_toc(sidebar.at_css('.gc-toc > ul'), [], '> [data-title]')
            new_toc = dash.get_toc_numbers($toc)
        end

        # remove some header/footer/sidebar elements that are unnecessary
        to_destroy = [
            docHtml.at_css('#gc-googlebar .gc-social'),
            docHtml.at_css('#gc-googlebar form'),
            docHtml.at_css('#gc-topnav'),
            docHtml.at_css('#gc-appbar'),
            docHtml.at_css('#gc-footer'),
            sidebar,
        ]
        to_destroy.each do |elem|
            if elem
                elem.remove
            # else
            #     puts entry
            end
        end

        if /\/docs\//.match(entry) && gc_content
            list = gc_content.at_css('.toc')
            if !list
                list = gc_content.css('ul,ol').first()
            end

            if list
                # puts entry
                page_toc = get_toc(list)

                def insert_toc_anchors(docRef, arr, type = 'Section', insert = false)
                    base_path = 'docs/' + docRef.url.split('/docs/').pop

                    arr.each do |toc_obj|
                        toc_name = toc_obj.keys.shift
                        info = toc_obj[toc_name]
                        href = info[:node]['href']

                        if href && /^#/.match(href)
                            path   = base_path + href
                            target = docRef.at_css(href)
                            if target
                                name = (info[:prefix]) ? info[:prefix] + '  ' + toc_name : toc_name
                                a    = $dash.get_dash_anchor(docRef, name, type, '')
                                target.before(a)
                                # puts name

                                if (insert)
                                    $dash.sql_insert(name, type, path)
                                end
                            end
                        end

                        if info[:subset].length
                            insert_toc_anchors(docRef, info[:subset], type)
                        end
                    end
                end


                if /\/protocol\//.match(entry)

                elsif /console\-api/.match(entry)
                    insert_toc_anchors(docHtml, page_toc, 'Method', true)

                elsif /commandline\-api/.match(entry)
                    insert_toc_anchors(docHtml, page_toc, 'Command', true)

                else
                    sub_toc = dash.get_toc_numbers(page_toc, '', 'Section', false)
                    if sub_toc.length > 0
                        insert_toc_anchors(docHtml, sub_toc, 'Section')
                    end
                end
            end

            dash.save_noko_doc(docHtml, entry, false)
        end
    end
end


# dash.sql_execute({
#     :noop => true,
#     :filter => {
#         # :limit => 5,
#         :type => 'Guide',
#         :name => '\s5\.'
#     }
# })
dash.sql_execute

dash.copy_docs

puts "\nAll Done!"
