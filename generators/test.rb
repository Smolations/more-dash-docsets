require File.join(File.dirname(__FILE__), 'Dash.module.rb')

def sql_insert(*args)
    if args.length == 3
        puts args.join(' | ')

    elsif args.length == 1
        puts "its a query"
    end
end


sql_insert('ui ama query')
