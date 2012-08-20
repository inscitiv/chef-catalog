action :execute do
  Conjur::Sudoers.sync new_resource.exclude_groups, new_resource.include_groups, new_resource.owner
end