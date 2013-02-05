class ActiveRecord::Base
  class << self
   
    @@connection_handlers ||= {}
   
    def connection_handler_with_multi_db_support(spec_symbol = nil)
      return @@connection_handlers[spec_symbol] if spec_symbol
      if Thread.current[:current_db]
        @@connection_handlers[Thread.current[:current_db]] ||= ActiveRecord::ConnectionAdapters::ConnectionHandler.new
      else
        connection_handler_without_multi_db_support
      end
    end
    
    alias_method :connection_handler_without_multi_db_support, :connection_handler      
    alias_method :connection_handler, :connection_handler_with_multi_db_support

    def switch_db(db, &block)
      Thread.current[:current_db] = db
      unless ActiveRecord::Base.connection_handler.retrieve_connection_pool(ActiveRecord::Base)
        ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[db])
      end
      yield
    ensure
      ActiveRecord::Base.connection_handler.clear_active_connections! rescue puts "supressing error while clearing connections - #{$!.inspect}"
      Thread.current[:current_db] = nil
    end
    
  end
end