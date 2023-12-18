vim9script
export def ApplySettings()
g:vim9skk.roman_table->extend({
kn: 'かん', sn: 'さん', tn: 'たん', 'n;': 'なん', hn: 'はん', fn: 'ふぁん', mz: 'まん', yn: 'やん', rn: 'らん', wn: 'わん',
'k;': 'きん', sk: 'しん', tk: 'ちん', nk: 'にん', hk: 'ひん', fk: 'ふぃん', mk: 'みん', rk: 'りん', wk: 'うぃん',
kj: 'くん', sj: 'すん', tj: 'つん', nj: 'ぬん', hj: 'ふん', fj: 'ふん', mj: 'むん', yj: 'ゆん', rj: 'るん',
kd: 'けん', sd: 'せん', td: 'てん', nd: 'ねん', hd: 'へん', fd: 'ふぇん', md: 'めん', rd: 'れん',
kl: 'こん', sl: 'そん', tl: 'とん', nl: 'のん', hl: 'ほん', fl: 'ふぉん', ml: 'もん', yl: 'よん', rl: 'ろん',
kq: 'かい', sq: 'さい', tq: 'たい', nq: 'ない', hq: 'はい', fq: 'ふぁい', mq: 'まい', yq: 'やい', rq: 'らい', wq: 'わい',
kh: 'くう', sh: 'すう', th: 'つう', nh: 'ぬう', 'h;': 'ふう', fh: 'ふぉう', mh: 'むう', yh: 'ゆう', rh: 'るう',
kw: 'けい', sw: 'せい', tw: 'てい', nw: 'ねい', hw: 'へい', fw: 'ふぇい', mw: 'めい', rw: 'れい',
kp: 'こう', sp: 'そう', tp: 'とう', np: 'のう', hp: 'ほう', fp: 'ふぉー', mp: 'もう', yp: 'よう', rp: 'ろう', wp: 'うぉー',
gn: 'がん', zn: 'ざん', dn: 'だん', bn: 'ばん', pn: 'ぱん',
gk: 'ぎん', zk: 'じん', dk: 'ぢん', bk: 'びん', pk: 'ぴん',
gj: 'ぐん', zj: 'ずん', dj: 'づん', bj: 'ぶん', pj: 'ぷん',
gd: 'げん', zd: 'ぜん', 'd;': 'でん', bd: 'べん', pd: 'ぺん',
gl: 'ごん', zl: 'ぞん', dl: 'どん', bl: 'ぼん', pl: 'ぽん',
gq: 'がい', zq: 'ざい', dq: 'だい', bq: 'ばい', pq: 'ぱい',
gh: 'ぐう', zh: 'ずう', dh: 'づう', bh: 'ぶう', ph: 'ぷう',
gw: 'げい', zw: 'ぜい', dw: 'でい', bw: 'べい', pw: 'ぺい',
gp: 'ごう', zp: 'ぞう', dp: 'どう', bp: 'ぼう', pP: 'ぽう',
kf: 'き', jf: 'じゅ', hf: 'ふ', yf: 'ゆ', mf: 'む', nf: 'ぬ', df: 'で', cf: 'ちぇ', pf: 'ぽん',
zc: 'ざ', zf: 'ぜ',
wf: 'わい', sf: 'さい', 's;': 'せい', zv: 'ざい', zx: 'ぜい',
wso: 'うぉ',
kya: 'きゃ', kga: 'きゃ', sya: 'しゃ', xa: 'しゃ', tya: 'ちゃ', ca: 'ちゃ', nya: 'にゃ', nga: 'にゃ', hya: 'ひゃ', hga: 'ひゃ', mya: 'みゃ', mga: 'みゃ', rya: 'りゃ',
kyu: 'きゅ', kgu: 'きゅ', syu: 'しゅ', xu: 'しゅ', tyu: 'ちゅ', cu: 'ちゅ', nyu: 'にゅ', ngu: 'にゅ', hyu: 'ひゅ', hgu: 'ひゅ', myu: 'みゅ', mgu: 'みゅ', ryu: 'りゅ',
kye: 'きぇ', kge: 'きぇ', sye: 'しぇ', xe: 'しぇ', tye: 'ちぇ', ce: 'ちぇ', nye: 'にぇ', nge: 'にぇ', hye: 'ひぇ', hge: 'ひぇ', mye: 'みぇ', mge: 'みぇ', rye: 'りぇ',
kyo: 'きょ', kgo: 'きょ', syo: 'しょ', xo: 'しょ', tyo: 'ちょ', co: 'ちょ', nyo: 'にょ', ngo: 'にょ', hyo: 'ひょ', hgo: 'ひょ', myo: 'みょ', mgo: 'みょ', ryo: 'りょ',
kyz: 'きゃん', kgz: 'きゃん', syz: 'しゃん', xz: 'しゃん', tyz: 'ちゃん', cz: 'ちゃん', nyz: 'にゃん', ngz: 'にゃん', hyz: 'ひゃん', hgz: 'ひゃん', myz: 'みゃん', mgz: 'みゃん', ryz: 'りゃん',
Kyn: 'きゃん', kgn: 'きゃん', syn: 'しゃん', xn: 'しゃん', tyn: 'ちゃん', cn: 'ちゃん', nyn: 'にゃん', ngn: 'にゃん', hyn: 'ひゃん', hgn: 'ひゃん', myn: 'みゃん', mgn: 'みゃん', ryn: 'りゃん',
kyj: 'きゅん', kgj: 'きゅん', syj: 'しゅん', xj: 'しゅん', tyj: 'ちゅん', cj: 'ちゅん', nyj: 'にゅん', ngj: 'にゅん', hyj: 'ひゅん', hgj: 'ひゅん', myj: 'みゅん', mgj: 'みゅん', ryj: 'りゅん',
kyd: 'きぇん', kgd: 'きぇん', syd: 'しぇん', xd: 'しぇん', tyd: 'ちぇん', cd: 'ちぇん', nyd: 'にぇん', ngd: 'にぇん', hyd: 'ひぇん', hgd: 'ひぇん', myd: 'みぇん', mgd: 'みぇん', ryd: 'りぇん',
kyl: 'きょん', kgl: 'きょん', syl: 'しょん', xl: 'しょん', tyl: 'ちょん', cl: 'ちょん', nyl: 'にょん', ngl: 'にょん', hyl: 'ひょん', hgl: 'ひょん', myl: 'みょん', mgl: 'みょん', ryl: 'りょん',
kyq: 'きゃい', kgq: 'きゃい', syq: 'しゃい', xq: 'しゃい', tyq: 'ちゃい', cq: 'ちゃい', nyq: 'にゃい', ngq: 'にゃい', hyq: 'ひゃい', hgq: 'ひゃい', myq: 'みゃい', mgq: 'みゃい', ryq: 'りゃい',
kyh: 'きゅう', kgh: 'きゅう', syh: 'しゅう', xh: 'しゅう', tyh: 'ちゅう', ch: 'ちゅう', nyh: 'にゅう', ngh: 'にゅう', hyh: 'ひゅう', hgh: 'ひゅう', myh: 'みゅう', mgh: 'みゅう', ryh: 'りゅう',
kyw: 'きぇい', kgw: 'きぇい', syw: 'しぇい', xw: 'しぇい', tyw: 'ちぇい', cw: 'ちぇい', nyw: 'にぇい', ngw: 'にぇい', hyw: 'ひぇい', hgw: 'ひぇい', myw: 'みぇい', mgw: 'みぇい', ryw: 'りぇい',
kyp: 'きょう', kgp: 'きょう', syp: 'しょう', xp: 'しょう', typ: 'ちょう', cp: 'ちょう', nyp: 'にょう', ngp: 'にょう', hyp: 'ひょう', hgp: 'ひょう', myp: 'みょう', mgp: 'みょう', ryp: 'りょう',
kt: 'こと', st: 'した', 't;': 'たち', ht: 'ひと',
wt: 'わた', mn: 'もの', ms: 'ます', ds: 'です',
km: 'かも', tm: 'ため', dm: 'でも', kr: 'から',
sr: 'する', tr: 'たら', nr: 'なる', yr: 'よる',
rR: 'られ', zr: 'ざる', mt: 'また', tb: 'たび',
nb: 'ねば', bt: 'びと', gr: 'がら', gt: 'ごと',
nt: 'にち', dt: 'だち', wr: 'われ',
sm: 'しま',
'_h': '←', '_j': '↓', '_k': '↑', '_l': '→',
})
enddef
