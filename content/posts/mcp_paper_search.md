---
title: "AI論文検索MCPを使ってみる：Consensus・Scholar Gateway・PubMed比較"
date: 2026-04-28T20:00:00+09:00
draft: false
tags: [AI, 研究, 論文検索, MCP, Claude, 音響生態学]
---

## はじめに

最近、Claude CoworkとZotero・ObsidianをMCPで繋いで、論文読みのためのワークフローを構築した。大まかな流れは「AIに論文を検索させる→気になったものをZoteroに登録する→Obsidianでメモを取る」というもので、それなりに快適に動いている。

今回はその最初のステップ、**AIによる論文検索**に使えるMCPを比較したい。試したのは以下の3つ：

- **[Consensus](https://consensus.app/)**: 2億件以上の査読済み論文をカバーするAI論文検索エンジン
- **[Scholar Gateway](https://scholargateway.ai/)**: Wiley が提供するセマンティック検索MCP
- **[PubMed](https://pubmed.ncbi.nlm.nih.gov/)**: 生命科学・医学系の定番データベース

比較のために、以下の2つのお題で実際に検索させてみた。

**お題1**：「自然環境における人工音ノイズを面的に定量化する方法について調べて」（専門分野：音響生態学）

**お題2**：「基盤モデルとSim2Realを切り口に、医療画像解析の最近の動向について調べて」（汎用性テスト）

どちらも日本語のお題からClaude (Sonnet 4.6)に英語クエリを生成させ、それを各MCPに投げる形で試した。

---

## お題1：自然環境における人工音ノイズの面的定量化

生成された英語クエリ：`spatial quantification methods for anthropogenic noise in natural environments soundscape ecology`

### Consensus

**10件ヒット。かなり直接的に関連した論文が並んだ。**

特に印象的だったのは以下：

- **Soundscape Analysis and Mapping System (SAMS)**（Liu et al., 2020）: Google Earthと連携してサウンドスケープデータを地理情報と統合するソフトウェアの論文。お題とど真ん中。
- **Soundscape mapping with remote sensing predictors**（Quinn et al., 2024）: ランドカバー・植生構造・人為的インパクトなどから音響指標を予測するモデル。空間補間でカバレッジを広げるアプローチが紹介されている。
- **Sound Mapping Tools toolbox**（Keyel et al., 2018）: 音の物理的伝播モデルを使って景観スケールで騒音フットプリントを可視化するツール。
- **Spatiotemporal Heterogeneity of Forest Park Soundscapes**（Zhuo et al., 2025）: 深層学習でbiophony/geophony/anthropophonyを分類してから時空間分布を解析する手法。

実際に「面的定量化」に使えるツールや手法に絞って結果が返ってきていて、非常に使いやすい。論文ごとのcitation数も表示されるのが地味に便利。

### Scholar Gateway

**5件（ユニーク論文）ヒット。ただし、返ってきたのは論文全体ではなく「パッセージ」形式。**

ヒットした論文は：
- Wilson et al. (2021, *Global Change Biology*): 人工光と人工音の複合効果が北米の鳥類分布に与える影響
- Klingbeil et al. (2019, *Global Ecology and Biogeography*): 繁殖鳥の人工音汚染との地理的関連
- Cox et al. (2024, *Frontiers in Ecology and the Environment*): 海洋生態系におけるサウンドスケープ保全
- Rosa & Koper (2018, *Ecosphere*): 多分野統合による人工音の動物コミュニケーションへの影響研究

音響生態学として関連性は高いが、「面的定量化の方法論」というよりは「人工音の影響評価」に寄っている印象。カバレッジがWiley系ジャーナルに偏っているためか、Consensusより視野が狭い。

Consensusとの大きな違いとして、パッセージ（論文の一部抜粋）が返ってくる点がある。関連箇所を直接読める反面、論文全体の概要を掴みにくい。

### PubMed

**0件。**

これは予想通りで、音響生態学はPubMedの対象範囲（生命科学・医学）から外れている。PubMed自体は何も悪くない。

---

## お題2：基盤モデルとSim2Realを切り口にした医療画像解析

生成された英語クエリ：`recent advances in medical image analysis using foundation models and sim-to-real transfer learning`

### Consensus

**10件ヒット。Foundation modelの論文は多数見つかったが、Sim2Realはゼロ。**

基盤モデル関連：
- Phuntsho et al. (2025, *ArXiv*): Foundation modelsのmedical imaging適応に関するサーベイ
- Azad et al. (2023, *ArXiv*): Foundation modelsの医療画像分野への包括的サーベイ
- Zhang et al. (2023, *Medical Image Analysis*): 医療用Foundation modelsの課題と展望

これらはいずれも質が高い論文で、サーベイ系が中心。

ただし、**Sim2Real（シミュレーションから実環境への転移）というキーワードに対応した論文は1件もなかった**。これはSim2Realが医療画像よりもロボット工学・コンピュータビジョン（合成データ活用）文脈の用語であることが影響していると思われる。

Sim2Realを医療画像解析に絡めた研究は最近増えているはずなので、クエリの表現方法をもう少し工夫する必要がありそう。

### Scholar Gateway

**6件（ユニーク論文）ヒット。2024〜2026年の最新論文が多い。**

- Nair et al. (2026, *Medical Physics*): SAMとMedSAMをUNetと比較した神経解剖学的セグメンテーション研究。面白い結果として、「UNetがMedSAMを上回った」というFoundation model仮説への反証。
- Zhu et al. (2026, *IJIST*): PathMAEという自己教師あり学習によるクロスドメイン病理画像転移学習
- He et al. (2025, *Interdisciplinary Medicine*): 医療画像における生成AIの展望レビュー
- Gan et al. (2025, *WIREs*): 医療画像セグメンテーションの包括的レビュー

**Consensusより新しい論文が多い**（2026年のものも含む）点は印象的。Scholar GatewayはWileyの出版データを参照しているため、Wiley系ジャーナルの最新号まで収録が速いようだ。

Sim2Realについてはこちらも0件。

### PubMed

**0件。**

`sim-to-real`というキーワードがPubMedのMeSHに存在しないためゼロヒット。Foundation modelについても、医療画像解析という切り口では検索クエリが適切にマッチしなかった模様。

`foundation model medical image segmentation`などシンプルなキーワードにすればヒットするかもしれないが、今回の複合的なクエリには対応できなかった。

---

## まとめ

| | 音響生態学（Consensus） | 音響生態学（Scholar Gateway） | 音響生態学（PubMed） |
|---|---|---|---|
| ヒット件数 | 10件 | 5件（ユニーク） | **0件** |
| 関連性 | ◎ 直接的 | △ やや周辺 | — |
| 特徴 | 多様なジャーナル、citation数付き | Wiley限定、パッセージ形式、最新 | 生命科学専門、範囲外 |

| | 医療画像（Consensus） | 医療画像（Scholar Gateway） | 医療画像（PubMed） |
|---|---|---|---|
| ヒット件数 | 10件 | 6件（ユニーク） | **0件** |
| 関連性 | ◎ Foundation model関連は充実 | ◯ 最新論文が強い | — |
| Sim2Real | × なし | × なし | — |

**Consensusが一番使いやすかった。** 件数・関連性・情報量（citation, URL）のバランスが良く、専門外テーマでも的確に関連論文を引いてくる。

**Scholar Gatewayは「最新のWiley系論文を深掘りしたい」場面で強い。** パッセージ形式で本文の一部が直接読めるのは他にない特徴。MedSAMがUNetに負けた、という2026年の論文が出てきたのはびっくりした。

**PubMedは、医療・生命科学に特化した用途で真価を発揮するはず。** ただし今回のようにSim2Realや音響生態学などを絡めるとお手上げになる。純粋に臨床試験や疾患機序を調べるような用途で使うのが正解だろう。

---

## おわりに

Consensusが日本語での紹介記事が少ないのが不思議なくらいよくできていた。生態学系の論文でも十分機能するのが個人的に嬉しいポイント。

今後はZoteroとの組み合わせや、ヒットした論文をObsidianのノートに落とし込むフローについても書いていきたい。
