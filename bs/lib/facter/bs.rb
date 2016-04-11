Facter.add(:bs_is_running) do
  setcode do
    Facter::Core::Execution.exec('/usr/bin/docker inspect --format="{{ .State.Running }}" big-sibling')
  end
end

Facter.add(:bs_envs) do
  setcode do
    Facter::Core::Execution.exec("/usr/bin/docker inspect -format='{{range .Config.Env}}{{println .}}{{end}}' big-sibling")
  end
end

Facter.add(:bs_image) do
  setcode do
    Facter::Core:Execution.exec("/usr/bin/docker inspect -format='{{ .Config.Image }}' big-sibling")
  end
end


Facter.add(:bs_envs_hash) do
  setcode do
    env_hash = {}
    Facter.value(:bs_envs).split('\n').each do |env|
      key = env.split('=')[0]
      value = env.split('=')[1]
      env_hash[key] = value
    end

    env_hash
  end
end