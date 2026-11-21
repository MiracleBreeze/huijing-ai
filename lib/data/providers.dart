class ProviderSpec {
  final String id;
  final String name;
  final String mono;
  final String desc;
  final String base;
  final String protocol; // ark | openai | poll
  final bool needsKey;
  final String modelHint;

  const ProviderSpec({
    required this.id,
    required this.name,
    required this.mono,
    required this.desc,
    required this.base,
    required this.protocol,
    this.needsKey = true,
    this.modelHint = '',
  });
}

const kProviders = [
  ProviderSpec(
    id: 'ark',
    name: '火山方舟',
    mono: 'A',
    desc: '豆包 Seedream 图像生成',
    base: 'https://ark.cn-beijing.volces.com/api/v3',
    protocol: 'ark',
    modelHint: 'doubao-seedream-5-5-261028',
  ),
  ProviderSpec(
    id: 'openai',
    name: 'OpenAI 官方',
    mono: 'O',
    desc: 'gpt-image 系列',
    base: 'https://api.openai.com/v1',
    protocol: 'openai',
    modelHint: 'gpt-image-1',
  ),
  ProviderSpec(
    id: 'gateway',
    name: '兼容网关',
    mono: 'G',
    desc: '任意 OpenAI 兼容接口',
    base: '',
    protocol: 'openai',
  ),
  ProviderSpec(
    id: 'poll',
    name: '免费测试',
    mono: 'P',
    desc: 'Pollinations · 免 Key',
    base: 'https://image.pollinations.ai',
    protocol: 'poll',
    needsKey: false,
  ),
];

ProviderSpec providerById(String id) => kProviders.firstWhere(
      (p) => p.id == id,
      orElse: () => kProviders.first,
    );
