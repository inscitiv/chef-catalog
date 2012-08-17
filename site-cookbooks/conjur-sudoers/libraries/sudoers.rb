module Conjur
  module Sudoers
    # Remove named groups from sudoers.
    # Add named groups to sudoers.
    
    # TODO: search for packages using ldap
    # libldap2-dev, libsasl2-dev, gem ruby-ldap
    
    # http://www.tutorialspoint.com/ruby/ruby_ldap.htm
    # conn.bind("prj=platform,dc=conjur,dc=inscitivops,dc=com,o=root", "08b77c589fc6f76034e234c5365bf20741fbbb53")
    # conn.search("prj=platform,dc=conjur,dc=inscitivops,dc=com,o=members", LDAP::LDAP_SCOPE_SUBTREE, '(objectclass=group)') do |entry|
    #   puts entry.dn
    # end
    # > cn=Developer, prj=platform, dc=conjur, dc=inscitivops, dc=com, o=members
    # > cn=Manager, prj=platform, dc=conjur, dc=inscitivops, dc=com, o=members
    
    def parseable?
      `augtool "match /augeas/files/etc/sudoers/error"`.match("/augeas/files/etc/sudoers/error") == 0
    end
    
    def sync(remove_groups, add_groups, add_user = nil, base = '/')
      require 'augeas'
      Augeas::open(base) do |aug|
        raise "No /etc/sudoers file" unless aug.match("/files/etc/sudoers")
        
        for group in (remove_groups||[])
          unless aug.match("/files/etc/sudoers/spec[user='%#{group}']").empty?
            puts "Removing %#{group}"
            puts aug.rm("/files/etc/sudoers/spec[user='%#{group}']")
          end
        end
        for group in (add_groups||[])
          puts "Adding %#{group}"
          add_sudo_user aug, "%#{group}"
        end
        if add_user
          puts "Adding #{add_user}"
          add_sudo_user aug, add_user
        end
        begin
          aug.save!
        rescue Object => e
          if err = aug.get('/augeas/files/etc/sudoers/error/message')
            raise "Augeas error on /etc/sudoers line #{aug.get '/augeas/files/etc/sudoers/error/line'}: #{err}"
          else
            raise e
          end
        end
      end
    end
  
    private
    
    def add_sudo_user(aug, user)
      aug.set("/files/etc/sudoers/spec[user='#{user}']/user", user)
      aug.set("/files/etc/sudoers/spec[user='#{user}']/host_group/host", "ALL")
      aug.set("/files/etc/sudoers/spec[user='#{user}']/host_group/command", "ALL") 
      aug.set("/files/etc/sudoers/spec[user='#{user}']/host_group/command/runas_user", "ALL")
      aug.set("/files/etc/sudoers/spec[user='#{user}']/host_group/command/tag", "NOPASSWD")
    end
    
  
    extend self
  end
end
