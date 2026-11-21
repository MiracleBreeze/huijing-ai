import 'package:flutter/material.dart';

import '../app.dart';
import '../data/providers.dart';
import '../services/media.dart';
import '../theme.dart';
import '../widgets/sheets.dart';
import '../widgets/ui.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = app.settings;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      children: [
        Text('设置', style: t(22, FontWeight.w600)),
        const SizedBox(height: 12),
        Text('服务商', style: t(12, FontWeight.w500, C.out)),
        const SizedBox(height: 8),
        for (final p in kProviders) _providerCard(context, p),
        const SizedBox(height: 18),
        Text('接入参数', style: t(12, FontWeight.w500, C.out)),
        const SizedBox(height: 8),
        fieldLabel('接口地址'),
        TextFormField(
          key: ValueKey('base-${s.providerId}'),
          initialValue: s.base(),
          style: t(12.5),
          decoration: const InputDecoration(hintText: 'https://…/v1'),
          onChanged: app.setBase,
        ),
        if (s.provider.needsKey) ...[
          const SizedBox(height: 12),
          fieldLabel('API Key'),
          TextFormField(
            key: ValueKey('key-${s.providerId}'),
            initialValue: s.key(),
            obscureText: true,
            style: t(12.5),
            decoration: const InputDecoration(hintText: 'sk-…'),
            onChanged: app.setKey,
          ),
        ],
        const SizedBox(height: 12),
        fieldLabel('模型'),
        InkWell(
          onTap: () => showModelSheet(context),
          borderRadius: BorderRadius.circular(R.l),
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: C.s1,
              borderRadius: BorderRadius.circular(R.l),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    s.model().isEmpty ? '未选择 · 点这里拉取' : s.model(),
                    style: t(12.5, FontWeight.w400,
                        s.model().isEmpty ? C.out : C.on),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, size: 18, color: C.out),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text('生成', style: t(12, FontWeight.w500, C.out)),
        const SizedBox(height: 8),
        _switchRow('右下角水印', s.watermark, (v) => app.toggleWatermark()),
        _switchRow('多图平铺（对话模式）', s.grid, (v) => app.toggleGrid()),
        const SizedBox(height: 18),
        Text('数据', style: t(12, FontWeight.w500, C.out)),
        const SizedBox(height: 8),
        _linkRow(
          '导出备份',
          Icons.ios_share_rounded,
          () => Media.shareText(
            '绘境 AI 备份 · ${app.works.length} 件作品\n${s.toJson()}',
            name: 'huijing-backup',
          ),
        ),
        _dangerRow('清空本地作品与对话', () async {
          final ok = await showDialog<bool>(
            context: context,
            builder: (c) => AlertDialog(
              backgroundColor: C.s2,
              title: Text('清空全部？', style: t(16, FontWeight.w600)),
              content: Text('本地作品和对话都会删掉，接口配置保留。',
                  style: t(12.5, FontWeight.w400, C.onv)),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(c, false),
                    child: Text('取消',
                        style: t(12.5, FontWeight.w400, C.onv))),
                TextButton(
                    onPressed: () => Navigator.pop(c, true),
                    child: Text('清空',
                        style: t(12.5, FontWeight.w500, C.err))),
              ],
            ),
          );
          if (ok == true) app.clearAll();
        }),
        const SizedBox(height: 20),
        Center(
          child: Text('绘境 AI · 1.9.3', style: t(11, FontWeight.w400, C.out)),
        ),
      ],
    );
  }

  Widget _providerCard(BuildContext context, ProviderSpec p) {
    final on = app.settings.providerId == p.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => app.setProvider(p.id),
        borderRadius: BorderRadius.circular(R.l),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: on ? C.accent.withValues(alpha: 0.1) : C.s1,
            borderRadius: BorderRadius.circular(R.l),
            border: Border.all(
              color: on ? C.accent.withValues(alpha: 0.45) : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    color: C.s3, shape: BoxShape.circle),
                child: Text(p.mono, style: t(14, FontWeight.w600, C.onv)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name, style: t(14, FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(p.desc, style: t(11, FontWeight.w400, C.out)),
                  ],
                ),
              ),
              if (on)
                const Icon(Icons.check_circle_rounded,
                    size: 18, color: C.accent)
              else
                const Icon(Icons.circle_outlined, size: 18, color: C.outv),
            ],
          ),
        ),
      ),
    );
  }

  Widget _switchRow(String title, bool value, ValueChanged<bool> on) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(child: Text(title, style: t(13.5, FontWeight.w400)),
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

  Widget _linkRow(String title, IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 18, color: C.onv),
              const SizedBox(width: 10),
              Expanded(child: Text(title, style: t(13.5)),
              ),
            ],
          ),
        ),
      );

  Widget _dangerRow(String title, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: 18, color: C.err),
              const SizedBox(width: 10),
              Expanded(child: Text(title, style: t(13.5, FontWeight.w400, C.err)),
              ),
            ],
          ),
        ),
      );
}
