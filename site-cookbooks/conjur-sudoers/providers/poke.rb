action :execute do
  Conjur::Sudoers.sync exclude_groups, include_groups, owner
end