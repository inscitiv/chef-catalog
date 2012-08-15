module Conjur::Sudoers
  # Remove named groups from sudoers.
  # Add named groups to sudoers.
  def sync(remove, add, base = '/')
    require 'augeas'
    Augeas::open(base) do |aug|
      for group in (remove||[])
        aug.rm("/files/etc/sudoers/spec[user='%#{group}']")
      end
      for group in (add||[])
        unless aug.exists("/files/etc/sudoers/spec[user='%#{group}']")
          c = aug.match("/files/etc/sudoers/spec").size
          aug.set("/files/etc/sudoers/spec[#{c}]/user", "%#{group}")
          aug.set("/files/etc/sudoers/spec[#{c}]/host_group/host", "ALL")
          aug.set("/files/etc/sudoers/spec[#{c}]/host_group/command", "ALL") 
          aug.set("/files/etc/sudoers/spec[#{c}]/host_group/command/runas_user", "ALL")
          aug.set("/files/etc/sudoers/spec[#{c}]/host_group/command/tag", "NOPASSWD")
        end
      end
      aug.save!
    end
  end

  extend self
end
