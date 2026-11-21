import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app.dart';
import '../models.dart';
import '../services/api.dart';
import '../services/assistant.dart';
import '../services/store.dart';
import '../theme.dart';
import 'ui.dart';

Future<void> showParamsSheet(BuildContext context) async {
  await showAppSheet(context, initial: 0.72, children: [
    Text('生成参数', style: t(22, FontWeight.w600)),
    Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 6),
      child: Text(
        '${app.settings.provider.name} · ${app.settings.model().isEmpty ? '未选择模型' : app.settings.model()} · ${sizeFor(app.settings.ratio, app.settings.resolution)} px',
        style: t(12, FontWeight.w400, C.onv),
      ),
    ),
    const SectionTitle('画幅'),
    _ratioGrid(context),
    const SectionTitle('清晰度'),
    Wrap(
      spacing: 8,
      children: [
        for (final r in kResolutions)
          Pill(
            switch (r) { '1K' => '1K · 预览', '4K' => '4K · 超清', _ => '2K · 推荐' },
            on: app.settings.resolution == r,
            onTap: () {
              app.setResolution(r);
              Navigator.of(context).pop();
            },
          ),
      ],
    ),
    const SectionTitle('数量'),
    Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 1; i <= 10; i++)
          SizedBox(
            width: 52,
            child: Pill('$i',
                on: app.settings.count == i,
                onTap: () {
                  app.setCount(i);
                  Navigator.of(context).pop();
                }),
          ),
      ],
    ),
    const SizedBox(height: 8),
    _rowTile(
      context,
      title: '模型',
      sub: app.settings.model().isEmpty ? '未选择' : app.settings.model(),
      onTap: () {
        Navigator.of(context).pop();
        showModelSheet(context);
      },
    ),
    _switchTile('水印', '右下角「AI 生成」标识', app.settings.watermark,
        (v) => app.toggleWatermark()),
    const SizedBox(height: 10),
    SizedBox(
      height: 46,
      child: FilledButton(
        onPressed: () {
          Navigator.of(context).pop();
          showAssistantSheet(context);
        },
        style: FilledButton.styleFrom(
          backgroundColor: C.p,
          foregroundColor: C.onP,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(R.l)),
        ),
        child: Text('AI 助手 · 优化 / 灵感',
            style: t(13.5, FontWeight.w600, C.onP)),
      ),
    ),
  ]);
}

Widget _ratioGrid(BuildContext context) {
  return GridView.count(
    crossAxisCount: 4,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    mainAxisSpacing: 8,
    crossAxisSpacing: 8,
    childAspectRatio: 0.86,
    children: [
      for (final r in kRatios)
        GestureDetector(
          onTap: () {
            app.setRatio(r.label);
            Navigator.of(context).pop();
          },
          child: Container(
            decoration: BoxDecoration(
              color: app.settings.ratio == r.label
                  ? C.accent.withValues(alpha: 0.12)
                  : C.s2,
              borderRadius: BorderRadius.circular(R.l),
              border: Border.all(
                color: app.settings.ratio == r.label
                    ? C.accent.withValues(alpha: 0.55)
                    : Colors.transparent,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 26,
                  height: 26,
                  child: Center(
                    child: Container(
                      width: r.w >= r.h ? 26 : 26 * r.w / r.h,
                      height: r.w >= r.h ? 26 * r.h / r.w : 26,
                      decoration: BoxDecoration(
                        border: Border.all(color: C.onv, width: 1.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(r.label, style: t(11.5, FontWeight.w500)),
                Text(r.name, style: t(9.5, FontWeight.w400, C.out)),
              ],
            ),
          ),
        ),
    ],
  );
}

Widget _rowTile(BuildContext context,
    {required String title, required String sub, VoidCallback? onTap}) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: t(14, FontWeight.w500)),
                const SizedBox(height: 3),
                Text(sub, style: t(11, FontWeight.w400, C.out)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: C.out, size: 18),
        ],
      ),
    ),
  );
}

Widget _switchTile(String title, String sub, bool value, ValueChanged<bool> on) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: t(14, FontWeight.w500)),
              const SizedBox(height: 3),
              Text(sub, style: t(11, FontWeight.w400, C.out)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: on,
          activeThumbColor: C.p,
          activeTrackColor: C.s4,
        ),
      ],
    ),
  );
}

Future<void> showModelSheet(BuildContext context) async {
  var loading = false;
  String? err;
  await showAppSheet(context, initial: 0.6, children: [
    StatefulBuilder(builder: (context, setSheet) {
      final models = app.settings.liveModels();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('选择模型', style: t(22, FontWeight.w600)),
              const Spacer(),
              TextButton(
                onPressed: loading
                    ? null
                    : () async {
                        setSheet(() {
                          loading = true;
                          err = null;
                        });
                        try {
                          await app.fetchModels();
                        } catch (e) {
                          err = '$e'.replaceFirst('Exception: ', '');
                        }
                        setSheet(() => loading = false);
                      },
                child: loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: C.accent))
                    : Text('刷新', style: t(12.5, FontWeight.w500, C.accent)),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text('模型列表来自接口 /models，不内置默认',
                style: t(11.5, FontWeight.w400, C.out)),
          ),
          if (err != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(err!, style: t(11.5, FontWeight.w400, C.err)),
            ),
          if (models.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                  child: Text('还没有拉到模型，先点右上角「刷新」',
                      style: t(12, FontWeight.w400, C.out))),
            )
          else
            for (final m in models)
              InkWell(
                onTap: () {
                  app.setModel(m);
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                          child: Text(m,
                              style: t(
                                  13,
                                  app.settings.model() == m
                                      ? FontWeight.w600
                                      : FontWeight.w400))),
                      if (app.settings.model() == m)
                        const Icon(Icons.check_rounded,
                            size: 18, color: C.accent),
                    ],
                  ),
                ),
              ),
        ],
      );
    }),
  ]);
}

Future<void> showAssistantSheet(BuildContext context) async {
  var tab = 0;
  var busy = false;
  final input = TextEditingController();
  String output = '';
  List<String> ideas = [];

  await showAppSheet(context, initial: 0.7, children: [
    StatefulBuilder(builder: (context, setSheet) {
      Future<void> run() async {
        final text = input.text.trim();
        if (text.isEmpty) return;
        setSheet(() => busy = true);
        try {
          if (tab == 0) {
            final sys = polishSystem(app.settings.polishTier);
            try {
              output = await Api.chat(
                  settings: app.settings, system: sys, user: text);
            } catch (_) {
              output = localPolish(text);
            }
          } else {
            try {
              final raw = await Api.chat(
                  settings: app.settings,
                  system: ideaSystem(),
                  user: ideaUser(text),
                  temperature: 0.9);
              ideas = parseIdeas(raw);
              if (ideas.isEmpty) ideas = localIdeas(text);
            } catch (_) {
              ideas = localIdeas(text);
            }
            output = ideas.isEmpty ? localPolish(text) : ideas.join('\n');
          }
        } finally {
          setSheet(() => busy = false);
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AI 助手', style: t(22, FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              Pill('优化提示词', on: tab == 0, onTap: () => setSheet(() => tab = 0)),
              const SizedBox(width: 8),
              Pill('生成灵感', on: tab == 1, onTap: () => setSheet(() => tab = 1)),
            ],
          ),
          if (tab == 0) ...[
            const SectionTitle('力度'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tier in kTiers)
                  Pill(
                    tier.$2,
                    on: app.settings.polishTier == tier.$1,
                    onTap: () {
                      app.setPolishTier(tier.$1);
                      setSheet(() {});
                    },
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('只修错别字、标点、空格与分行；后三档在此基础上再精简/深入/加张力，不新增画面元素。',
                  style: t(11, FontWeight.w400, C.out)),
            ),
          ],
          const SizedBox(height: 14),
          TextField(
            controller: input,
            minLines: 3,
            maxLines: 6,
            style: t(13),
            decoration: InputDecoration(
              hintText: tab == 0 ? '粘贴或写下要修的提示词' : '一句话要求，比如：海边灯塔，夜里',
              fillColor: C.s2,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 44,
            width: double.infinity,
            child: FilledButton(
              onPressed: busy ? null : run,
              style: FilledButton.styleFrom(
                backgroundColor: C.p,
                foregroundColor: C.onP,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(R.l)),
              ),
              child: busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: C.onP))
                  : Text(tab == 0 ? '开始优化' : '生成 3 条灵感',
                      style: t(13.5, FontWeight.w600, C.onP)),
            ),
          ),
          if (output.isNotEmpty) ...[
            const SectionTitle('结果'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: C.s2,
                borderRadius: BorderRadius.circular(R.l),
              ),
              child: SelectableText(output, style: t(13, FontWeight.w400, C.on)),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: output));
                      if (context.mounted) Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: C.on,
                      side: const BorderSide(color: C.s4),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(R.l)),
                    ),
                    child: Text('复制并关闭', style: t(13, FontWeight.w500)),
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    }),
  ]);
}
