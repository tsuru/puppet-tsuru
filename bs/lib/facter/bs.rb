Facter.add('bs_is_running') do
  setcode do
    Facter::Core::Execution.exec('/usr/bin/docker inspect --format="{{ .State.Running }}" big-sibling')
  end
end