module Conjur
  module Sudoers
    def parseable?(base = '/')
      require 'augeas'
      Augeas::open(base) do |aug|
        aug.match("/augeas/files/etc/sudoers/error").empty?
      end
    end
    
    # Remove named groups from sudoers.
    # Add named groups to sudoers.
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
