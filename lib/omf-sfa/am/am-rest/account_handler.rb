
require 'omf-sfa/am/am-rest/rest_handler'
require 'omf-sfa/am/am-rest/resource_handler'

#require 'omf-sfa/resource/sliver'

module OMF::SFA::AM::Rest

  # Handles the collection of accounts on this AM.
  #
  class AccountHandler < RestHandler

    def initialize(am_manager, opts = {}) #constructor
      super
      @res_handler = ResourceHandler.new(am_manager, opts)
    end

    def find_handler(path, opts)
      account_id = opts[:resource_uri] = path.shift #vgazei to prwto, path = [account_id, comp]
      if account_id
        account = opts[:account] = find_account(account_id, opts)
      end
      return self if path.empty? #nomizw einai kati san debug

      case comp = path.shift #vgazei to deutero
      when 'resources'
        opts[:resource_uri] = path.join('/')
        #puts "RESOURCE >>> '#{r}'::#{account.inspect}"
        return @res_handler
      end
      raise UnknownResourceException.new "Unknown sub collection '#{comp}' for account '#{account_id}'."
    end

    def on_get(account_uri, opts)
      debug 'get: account_uri: "', account_uri, '"'
      if account_uri
        account = opts[:account]
        show_account_status(account, opts) #gurnaei h auto
      else
        show_accounts(opts) #h auto
      end
    end

    # def on_put(account_uri, opts)
      # account = opts[:account] = OMF::SFA::Resource::Sliver.first_or_create(:name => opts[:account_id])
      # configure_sliver(sliver, opts)
      # show_sliver_status(sliver, opts)
    # end

    def on_delete(account_uri, opts)
      account = opts[:account]
      @am_manager.delete_account(account) # UNUSED?

      show_account_status(nil, opts)
    end

    # SUPPORTING FUNCTIONS

    def show_account_status(account, opts)
      if account                                # praktika simainei "an uparxei"
        p = opts[:req].path.split('/')[0 .. -2] # spasto mexri to proteleutaio stoixeio
        p << account.uuid.to_s                  # vale sto telos tou pinaka
        prefix = about = p.join('/')            # ftiaxnei ena path me to uuid sto telos
        res = {                                 # hash
          :about => about,
          :type => 'account',
          :properties => {
              #:href => prefix + '/properties',
              :expires_at => (Time.now + 600).rfc2822
          },
          :resources => {:href => prefix + '/resources'},
          :policies => {:href => prefix + '/policies'},
          :assertion => {:href => prefix + '/assertion'}
        }
      else
        res = {:error => 'Unknown account'}
      end

      ['application/json', JSON.pretty_generate({:account_response => res})] #dimiourgei ena JSON apo to res
    end

    def show_accounts(opts)
      authenticator = opts[:req].session[:authorizer] # logika dimiourgei ena session me kati??
      prefix = about = opts[:req].path                # ena absolute path sta accounts
      accounts = @am_manager.find_all_accounts(authenticator).collect do |a| # epistrefetai pinakas me ta accounts pou epitrepetai na dei o xristis
        {
          :name => a.name,
          :urn => a.urn,
          :uuid => uuid = a.uuid.to_s,
          :href => prefix + '/' + uuid
        }
      end
      res = {
        :about => opts[:req].path,
        :accounts => accounts
      }

      # Generate a JSON document from the Ruby data structure _obj_ and return it.
      ['application/json', JSON.pretty_generate({:accounts_response => res})] # auto pou epistrefei
    end

    # Configure the state of +account+ according to information
    # in the http +req+.
    #
    # Note: It doesn't actually modify the account directly, but parses the
    # the body and delegates the individual entries to the relevant
    # sub collections, like 'resources', 'policies', ...
    #
    def configure_account(account, opts)
      doc, format = parse_body(opts) # h parse_body gurnaei 2 pragmata (se pinaka) to deutero einai to format twn opt
      case format
      when :xml
        doc.xpath("//r:resources", 'r' => 'http://schema.mytestbed.net/am_rest/0.1').each do |rel| # Search this NodeSet for XPath +paths+
          @res_handler.put_components_xml(rel, opts)
        end
      else
        raise BadRequestException.new "Unsupported message format '#{format}'"
      end
    end

    def find_account(account_id, opts) #account_id: urn or uuid or name
      if account_id.start_with?('urn')
        fopts = {:urn => account_id} #Hash
      else
        begin
          fopts = {:uuid => UUIDTools::UUID.parse(account_id)} #Parses a UUID from a string
        rescue ArgumentError
          fopts = {:name => account_id}
        end
      end
      authenticator = opts[:req].session[:authorizer]
      account = @am_manager.find_account(fopts, authenticator) #returns account
    end
  end
end
