import yaml
import json

with open('agents/config.yml') as f:
    cfg = yaml.safe_load(f)

opencode_cfg = cfg.get('agent_config', {}).get('opencode', {})

with open('.opencode/opencode.json', 'w') as f:
    json.dump(opencode_cfg, f, indent=2)

print('Generated .opencode/opencode.json:')
print(json.dumps(opencode_cfg, indent=2))
