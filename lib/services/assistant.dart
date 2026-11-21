const kTiers = [
  ('fix', '只修格式', '只修复错别字、标点、空格与分行，不新增任何画面内容'),
  ('brief', '+ 更精简', '修完格式后，删掉重复与啰嗦，句子更短'),
  ('deep', '+ 更深入', '修完格式后，把笼统词换成更具体、可拍的视觉描述'),
  ('punch', '+ 更有张力', '修完格式后，调整语序与节奏，让画面更有冲击力'),
];

const _tail = '只输出改好的提示词本身，不要解释、不要加前缀、不要扩写题材或新增元素。';

String polishSystem(String tier) {
  final extra = switch (tier) {
    'brief' => '在完成格式修复之后，删掉重复表述与废话，保持信息量不变、句子更紧凑。',
    'deep' => '在完成格式修复之后，把含糊的词替换为具体可拍的视觉描述，仍不新增元素。',
    'punch' => '在完成格式修复之后，调整语序和断句，让主体更突出、画面更有张力，仍不新增元素。',
    _ => '只做修复：错别字、全半角标点、多余空格与换行、把分点/编号/引号合并成一段通顺的话。',
  };
  return '你是提示词排版助手。$extra $_tail';
}

String ideaSystem() =>
    '你是图像提示词助手。根据用户一句话要求，给出 3 条可直接用于生图的中文提示词，每条一行，' 
    '包含主体、场景、光线与景别，不要编号以外的解释。';

String ideaUser(String seed) => '要求：$seed\n请给 3 条不同的画面方案。';

List<String> parseIdeas(String raw) {
  final lines = raw
      .split('\n')
      .map((e) => e.replaceFirst(RegExp(r'^[\-\*\d\.、\s]+'), '').trim())
      .where((e) => e.length > 4)
      .toList();
  if (lines.length >= 3) return lines.take(3).toList();
  return lines;
}
