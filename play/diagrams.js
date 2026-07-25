/* ============================================================================
 * CUS — THE DIAGRAM LIBRARY
 * v1.0 · the visual grammar, drawn once · 2026-07-25
 * ----------------------------------------------------------------------------
 * Every instructional image in First Battle is built from this file. The token
 * language is fixed (PLAY_FIRST_BATTLE_SCREENMAP.md §0.2) and lifted from the
 * footer of HOW_TO_PLAY_v1_5.html — it is not new, it is what already ships:
 *
 *   BLACK solid base    the figure currently acting
 *   WHITE outlined base the figure receiving
 *   GREY base           present but irrelevant this screen
 *   DASHED base         where a figure WAS
 *   NOTCH on base edge  facing (Squares only — Circles have none)
 *   HATCHING            wall / impassable
 *   GOLD                movement · action · bonus · legal choice
 *   RED                 wound · death · failed check · illegal destination
 *   THIN RING           reach or effect distance
 *   BIG ARROW           forced movement
 *   SMALL CURVED ARROW  reface / rotate
 *
 * A diagram may not introduce a mark absent from that table. New marks are
 * added HERE first and then applied to every existing diagram.
 *
 * GEOMETRY. The board is 12in x 12in. SVG works in tenths of an inch, so the
 * viewBox is 0 0 120 120. Board y runs UP (north is far); SVG y runs DOWN.
 * Everything goes through sx()/sy() so no drawing code ever flips a sign.
 *
 * Base footprints, from B.1:  Small sq 20mm  Medium sq 25mm  Large sq 40mm
 *                             Small ci 25mm  Medium ci 32mm  Large ci 40mm
 * ========================================================================== */

window.CUS_DX = (function () {
  'use strict';

  var MM = 0.0393701;                 // mm -> inch
  var U  = 10;                        // svg units per inch
  var FIELD = 12;                     // board is 12in square

  function sx(bx) { return bx * U; }
  function sy(by) { return (FIELD - by) * U; }
  function inches(mm) { return mm * MM; }

  var FOOT = {
    'Square-Small': inches(20), 'Square-Medium': inches(25), 'Square-Large': inches(40),
    'Circle-Small': inches(25), 'Circle-Medium': inches(32), 'Circle-Large': inches(40)
  };
  function footprint(shape, size) { return FOOT[shape + '-' + size] || inches(25); }

  /* ------------------------------------------------------------------ MONO
   * Print is pure black and white. Desaturating is NOT enough: on a mono
   * laser, gold and red land on nearly the same grey, so a movement arrow
   * and a death marker stop being distinguishable — the grammar collapses.
   *
   * So in mono the signal moves from HUE to WEIGHT and PATTERN:
   *     action / move / bonus / legal  ->  heavy SOLID stroke, solid head
   *     wound / death / failure        ->  TWIN PARALLEL strokes, hollow head
   * Nothing is ever distinguished by tone alone.                          */
  var MONO = false;
  function mono(v) { MONO = (v !== false); return MONO; }

  var PAL = {
    screen: { ink:'var(--ink)', paper:'var(--paper)', mid:'var(--mid)', lt:'var(--lt)',
              faint:'var(--faint)', act:'var(--gold)', acttxt:'var(--goldtxt)',
              harm:'var(--red)', harmfill:'var(--redd)' },
    mono:   { ink:'#000', paper:'#fff', mid:'#555', lt:'#999',
              faint:'#bbb', act:'#000', acttxt:'#000',
              harm:'#000', harmfill:'#000' }
  };
  function C(k) { return (MONO ? PAL.mono : PAL.screen)[k]; }

  /* Tones map onto the token language. On screen the colours come from CSS
     custom properties, so light and dark both work from one drawing. */
  function tones() {
    return {
      acting:   { fill: C('ink'),   stroke: C('ink'),   text: C('paper'), w: 1.2 },
      receiving:{ fill: C('paper'), stroke: C('ink'),   text: C('ink'),   w: 1.6 },
      bystander:{ fill: 'none',     stroke: MONO ? '#999' : C('faint'), text: C('lt'), w: MONO ? 0.9 : 1.2 },
      was:      { fill: 'none',     stroke: C('lt'),    text: C('lt'),    w: 1.1, dash: '3 2.5' },
      dead:     { fill: C('harmfill'), stroke: C('harm'), text: C('paper'), w: 1.4 },
      legal:    { fill: 'none',     stroke: C('act'),   text: C('acttxt'), w: 1.6 }
    };
  }

  function esc(s) {
    return String(s == null ? '' : s)
      .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  }
  function n(v) { return Math.round(v * 1000) / 1000; }

  /* ---------------------------------------------------------------- defs
   * Hatching for walls, and the arrowheads. Emitted once per <svg>.      */
  function defs() {
    /* In mono the harm arrowhead is HOLLOW — outline only — so it reads
       differently from the solid action head even in pure black. */
    var harmHead = MONO
      ? '<path d="M0,0 L10,5 L0,10 z" fill="#fff" stroke="#000" stroke-width="1.6"/>'
      : '<path d="M0,0 L10,5 L0,10 z" fill="var(--red)"/>';
    return '' +
      '<defs>' +
        '<pattern id="dxhatch" width="4" height="4" patternUnits="userSpaceOnUse" patternTransform="rotate(45)">' +
          '<line x1="0" y1="0" x2="0" y2="4" stroke="' + C('mid') + '" stroke-width="1.4"/>' +
        '</pattern>' +
        '<marker id="dxarrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="5" markerHeight="5" orient="auto-start-reverse">' +
          '<path d="M0,0 L10,5 L0,10 z" fill="' + C('act') + '"/>' +
        '</marker>' +
        '<marker id="dxarrowred" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="5" markerHeight="5" orient="auto-start-reverse">' +
          harmHead +
        '</marker>' +
        '<marker id="dxarrowbig" viewBox="0 0 10 10" refX="7" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">' +
          '<path d="M0,0 L10,5 L0,10 z" fill="' + C('ink') + '"/>' +
        '</marker>' +
      '</defs>';
  }

  /* A twin-parallel stroke: lay a heavy dark line, then a thin paper-coloured
     line straight down its middle. The eye reads two rails, not one bar —
     which is how "harm" stays legible when it cannot be red. */
  function twinPath(d, head) {
    return '<path d="' + d + '" fill="none" stroke="' + C('harm') + '" stroke-width="3.4" ' +
             'stroke-linecap="butt"' + (head ? ' marker-end="' + head + '"' : '') + '/>' +
           '<path d="' + d + '" fill="none" stroke="' + C('paper') + '" stroke-width="1.1" ' +
             'stroke-linecap="butt"/>';
  }

  /* A bonus value, reversed out of a solid pill. Replaces gold "+2" text. */
  function bonusPill(x, y, text) {
    var w = 5.5 + String(text).length * 3.4;
    return '<rect x="' + n(x - w / 2) + '" y="' + n(y - 4.4) + '" width="' + n(w) + '" height="8.8" rx="4.4" ' +
             'fill="' + C('act') + '"/>' +
           '<text x="' + n(x) + '" y="' + n(y + 2.6) + '" text-anchor="middle" font-size="6" ' +
             'font-weight="700" fill="' + C('paper') + '" font-family="Helvetica,Arial,sans-serif">' +
             esc(text) + '</text>';
  }

  function svg(inner, opts) {
    opts = opts || {};
    var vb = opts.viewBox || ('0 0 ' + FIELD * U + ' ' + FIELD * U);
    return '<svg class="dx" viewBox="' + vb + '" role="img" ' +
           'aria-label="' + esc(opts.alt || 'diagram') + '" ' +
           'preserveAspectRatio="xMidYMid meet">' + defs() + inner + '</svg>';
  }

  /* ================================================================= BASE
   * One figure. The base IS the label — shape is type, footprint is size,
   * the notch is facing. Circles get no notch, ever (B.1: faceless).    */
  function base(f) {
    var shape = f.shape || 'Square';
    var size  = f.size  || 'Medium';
    var tone  = tones()[f.tone || 'bystander'];
    var w     = footprint(shape, size) * U;
    var cx    = sx(f.at[0]), cy = sy(f.at[1]);
    var out   = [];
    var dash  = tone.dash ? ' stroke-dasharray="' + tone.dash + '"' : '';

    if (shape === 'Circle') {
      out.push('<circle cx="' + n(cx) + '" cy="' + n(cy) + '" r="' + n(w / 2) + '" fill="' +
        tone.fill + '" stroke="' + tone.stroke + '" stroke-width="' + tone.w + '"' + dash + '/>');
    } else {
      out.push('<rect x="' + n(cx - w / 2) + '" y="' + n(cy - w / 2) + '" width="' + n(w) +
        '" height="' + n(w) + '" rx="1" fill="' + tone.fill + '" stroke="' + tone.stroke +
        '" stroke-width="' + tone.w + '"' + dash + '/>');
      /* NOTCH — facing. Squares only. A small wedge cut into the facing edge. */
      if (f.facing && f.tone !== 'was') {
        var h = w / 2, nw = w * 0.26;
        var pts = {
          N: [[cx - nw / 2, cy - h], [cx + nw / 2, cy - h], [cx, cy - h + nw * 0.72]],
          S: [[cx - nw / 2, cy + h], [cx + nw / 2, cy + h], [cx, cy + h - nw * 0.72]],
          E: [[cx + h, cy - nw / 2], [cx + h, cy + nw / 2], [cx + h - nw * 0.72, cy]],
          W: [[cx - h, cy - nw / 2], [cx - h, cy + nw / 2], [cx - h + nw * 0.72, cy]]
        }[f.facing];
        if (pts) {
          out.push('<polygon points="' + pts.map(function (p) { return n(p[0]) + ',' + n(p[1]); }).join(' ') +
            '" fill="' + (f.tone === 'acting' ? C('paper') : tone.stroke) + '"/>');
        }
      }
    }

    if (f.dead) {
      var r = w * 0.42, xw = MONO ? 2.8 : 2;
      out.push('<line x1="' + n(cx - r) + '" y1="' + n(cy - r) + '" x2="' + n(cx + r) + '" y2="' + n(cy + r) +
        '" stroke="' + C('harm') + '" stroke-width="' + xw + '" stroke-linecap="round"/>');
      out.push('<line x1="' + n(cx + r) + '" y1="' + n(cy - r) + '" x2="' + n(cx - r) + '" y2="' + n(cy + r) +
        '" stroke="' + C('harm') + '" stroke-width="' + xw + '" stroke-linecap="round"/>');
    }
    if (f.label) {
      out.push('<text x="' + n(cx) + '" y="' + n(cy + 1.6) + '" text-anchor="middle" ' +
        'font-size="5" font-weight="700" fill="' + tone.text + '" font-family="Helvetica,Arial,sans-serif">' +
        esc(f.label) + '</text>');
    }
    if (f.ring) {
      out.push('<circle cx="' + n(cx) + '" cy="' + n(cy) + '" r="' + n(f.ring * U) +
        '" fill="none" stroke="' + C('act') + '" stroke-width="0.9" stroke-dasharray="2.5 2.5" opacity="' +
        (MONO ? '1' : '.85') + '"/>');
    }
    if (f.halo) {
      out.push('<circle cx="' + n(cx) + '" cy="' + n(cy) + '" r="' + n(w * 0.78) +
        '" fill="none" stroke="' + C('act') + '" stroke-width="' + (MONO ? 2.2 : 1.6) + '" opacity="' +
        (MONO ? '1' : '.9') + '"/>');
    }
    return out.join('');
  }

  /* ================================================================ WALL */
  function wall(w) {
    var t = 3.2;
    var y = sy(w.y) - t / 2;
    var segs = [];
    var x0 = sx(w.from), x1 = sx(w.to);
    if (w.gapAt != null) {
      var g0 = sx(w.gapAt - (w.gapWidth || 1) / 2), g1 = sx(w.gapAt + (w.gapWidth || 1) / 2);
      segs.push([x0, g0], [g1, x1]);
    } else {
      segs.push([x0, x1]);
    }
    return segs.map(function (s) {
      return '<rect x="' + n(s[0]) + '" y="' + n(y) + '" width="' + n(s[1] - s[0]) + '" height="' + t +
        '" fill="url(#dxhatch)" stroke="' + C('mid') + '" stroke-width="0.8"/>';
    }).join('');
  }

  /* =========================================================== OBJECTIVE */
  function objective(o, dim) {
    var cx = sx(o.at[0]), cy = sy(o.at[1]);
    var op = dim ? '.35' : '1';
    /* Print cannot animate, so mono gets a static double ring instead of a
       pulse — still unmistakably "the thing you are trying to reach". */
    var halo = dim ? ''
      : (MONO
          ? '<circle cx="' + n(cx) + '" cy="' + n(cy) + '" r="8.5" fill="none" stroke="' + C('act') +
            '" stroke-width="0.8" stroke-dasharray="2 2"/>'
          : '<circle cx="' + n(cx) + '" cy="' + n(cy) + '" r="8.5" fill="none" stroke="' + C('act') + '" ' +
            'stroke-width="0.8" opacity=".55"><animate attributeName="r" values="7;10.5;7" dur="2.4s" ' +
            'repeatCount="indefinite"/><animate attributeName="opacity" values=".6;0;.6" dur="2.4s" ' +
            'repeatCount="indefinite"/></circle>');
    return '<g opacity="' + op + '">' +
      '<circle cx="' + n(cx) + '" cy="' + n(cy) + '" r="5.5" fill="none" stroke="' + C('act') + '" stroke-width="1.4"/>' +
      '<circle cx="' + n(cx) + '" cy="' + n(cy) + '" r="2.4" fill="' + C('act') + '"/>' +
      halo + '</g>';
  }

  /* ================================================================ PATH
   * Gold movement path: dashed origin base, path, live distance, ghost.  */
  function movePath(p) {
    var x0 = sx(p.from[0]), y0 = sy(p.from[1]);
    var x1 = sx(p.to[0]),   y1 = sy(p.to[1]);
    var mx  = (x0 + x1) / 2, my = (y0 + y1) / 2;
    var d   = 'M' + n(x0) + ',' + n(y0) + ' L' + n(x1) + ',' + n(y1);
    var col = p.illegal ? C('harm') : C('act');
    var out;
    if (p.illegal && MONO) {
      out = twinPath(d, 'url(#dxarrowred)');           /* twin rails = refused */
    } else {
      out = '<path d="' + d + '" fill="none" stroke="' + col + '" stroke-width="' +
            (MONO ? 2.2 : 1.8) + '" stroke-linecap="round" marker-end="' +
            (p.illegal ? 'url(#dxarrowred)' : 'url(#dxarrow)') + '"/>';
    }
    if (p.distance != null) {
      out += '<rect x="' + n(mx - 9) + '" y="' + n(my - 9) + '" width="18" height="7.5" rx="3.2" ' +
             'fill="' + C('paper') + '" stroke="' + col + '" stroke-width="0.8"/>' +
             '<text x="' + n(mx) + '" y="' + n(my - 3.6) + '" text-anchor="middle" font-size="5" ' +
             'font-weight="700" fill="' + col + '" font-family="Helvetica,Arial,sans-serif">' +
             esc(p.distance.toFixed(1)) + '"</text>';
    }
    return out;
  }

  /* ========================================================= STRIKE ARROW */
  function strike(a) {
    var x0 = sx(a.from[0]), y0 = sy(a.from[1]);
    var x1 = sx(a.to[0]),   y1 = sy(a.to[1]);
    var dx = x1 - x0, dy = y1 - y0, L = Math.sqrt(dx * dx + dy * dy) || 1;
    var pad = a.pad == null ? 5 : a.pad;
    var ax0 = x0 + dx / L * pad, ay0 = y0 + dy / L * pad;
    var ax1 = x1 - dx / L * pad, ay1 = y1 - dy / L * pad;
    var off = a.bow || 0;
    var mx = (ax0 + ax1) / 2 - dy / L * off, my = (ay0 + ay1) / 2 + dx / L * off;
    var d = 'M' + n(ax0) + ',' + n(ay0) + ' Q' + n(mx) + ',' + n(my) + ' ' + n(ax1) + ',' + n(ay1);
    /* A Counter is harm coming back at you. In colour that is red; in mono it
       is twin rails with a hollow head, so it never reads as your own blow. */
    if (a.counter && MONO) return twinPath(d, 'url(#dxarrowred)');
    return '<path d="' + d + '" fill="none" stroke="' + (a.counter ? C('harm') : C('act')) +
      '" stroke-width="' + (a.counter ? 1.3 : (MONO ? 2.2 : 1.9)) +
      '" stroke-linecap="round" marker-end="' +
      (a.counter ? 'url(#dxarrowred)' : 'url(#dxarrow)') + '"/>';
  }

  /* ===================================================== FORCED MOVEMENT */
  function bigArrow(a) {
    return '<line x1="' + n(sx(a.from[0])) + '" y1="' + n(sy(a.from[1])) +
      '" x2="' + n(sx(a.to[0])) + '" y2="' + n(sy(a.to[1])) +
      '" stroke="' + C('ink') + '" stroke-width="3.2" stroke-linecap="round" marker-end="url(#dxarrowbig)"/>';
  }

  /* ====================================================== REFACE (rotate) */
  function reface(at) {
    var cx = sx(at[0]), cy = sy(at[1]);
    return '<path d="M' + n(cx + 7) + ',' + n(cy - 7) + ' a 9.9 9.9 0 0 1 -3.2 8.2" fill="none" ' +
      'stroke="' + C('act') + '" stroke-width="1.3" marker-end="url(#dxarrow)"/>';
  }

  /* ================================================================ BOARD
   * The one renderer behind most of the tutorial's images. Everything is
   * driven by opts so a screen changes emphasis, never geometry.        */
  function board(o) {
    o = o || {};
    var g = [];
    if (o.wall) g.push(wall(o.wall));
    if (o.objective) g.push(objective(o.objective, o.dimObjective));
    (o.rings || []).forEach(function (r) {
      g.push('<circle cx="' + n(sx(r.at[0])) + '" cy="' + n(sy(r.at[1])) + '" r="' + n(r.r * U) +
        '" fill="none" stroke="' + (r.colour || C('act')) + '" stroke-width="1" stroke-dasharray="3 2.5"/>');
      if (r.label) {
        g.push('<text x="' + n(sx(r.at[0])) + '" y="' + n(sy(r.at[1]) - r.r * U - 2.5) + '" text-anchor="middle" ' +
          'font-size="4.6" font-weight="700" fill="' + C('acttxt') + '" font-family="Helvetica,Arial,sans-serif">' +
          esc(r.label) + '</text>');
      }
    });
    (o.paths   || []).forEach(function (p) { g.push(movePath(p)); });
    (o.figures || []).forEach(function (f) { g.push(base(f)); });
    (o.strikes || []).forEach(function (s) { g.push(strike(s)); });
    (o.arrows  || []).forEach(function (a) { g.push(bigArrow(a)); });
    (o.refaces || []).forEach(function (r) { g.push(reface(r)); });
    return svg(g.join(''), { alt: o.alt, viewBox: o.viewBox });
  }

  /* ============================================================== AP PIPS */
  function apPips(total, left) {
    var out = [], r = 5.5, gap = 15;
    for (var i = 0; i < total; i++) {
      var filled = i < left;
      out.push('<circle cx="' + (8 + i * gap) + '" cy="8" r="' + r + '" ' +
        'fill="' + (filled ? C('act') : 'none') + '" stroke="' + C('act') + '" stroke-width="1.4" ' +
        'opacity="' + (filled ? '1' : '.4') + '"/>');
    }
    return svg(out.join(''), { alt: left + ' of ' + total + ' AP remaining',
      viewBox: '0 0 ' + (total * gap) + ' 16' });
  }

  /* ================================================================= DICE */
  function dice(values, target) {
    var out = [], s = 22, gap = 27;
    values.forEach(function (v, i) {
      var hit = v >= target;
      var x = i * gap;
      out.push('<rect x="' + x + '" y="1" width="' + s + '" height="' + s + '" rx="4" ' +
        'fill="' + (hit ? C('act') : 'none') + '" stroke="' + (hit ? C('act') : C('faint')) +
        '" stroke-width="1.6" opacity="' + (hit ? '1' : '.75') + '"/>');
      out.push('<text x="' + (x + s / 2) + '" y="' + (s / 2 + 5) + '" text-anchor="middle" font-size="13" ' +
        'font-weight="700" font-family="Georgia,serif" fill="' + (hit ? C('paper') : C('lt')) + '">' +
        v + '</text>');
    });
    return svg(out.join(''), { alt: 'dice showing ' + values.join(', ') + ', hitting on ' + target + ' or more',
      viewBox: '0 0 ' + (values.length * gap) + ' ' + (s + 2) });
  }

  /* ========================================================= WOUND TRACK */
  function woundTrack(steps, reached) {
    var out = [], w = 40, h = 15, gap = 46;
    steps.forEach(function (label, i) {
      var on = i <= reached;
      var x = i * gap;
      out.push('<rect x="' + x + '" y="1" width="' + w + '" height="' + h + '" rx="3.5" ' +
        'fill="' + (on ? C('harmfill') : 'none') + '" stroke="' + (on ? C('harm') : C('faint')) +
        '" stroke-width="1.3"/>');
      out.push('<text x="' + (x + w / 2) + '" y="' + (h / 2 + 4) + '" text-anchor="middle" font-size="7.5" ' +
        'font-weight="700" font-family="Helvetica,Arial,sans-serif" letter-spacing=".6" ' +
        'fill="' + (on ? C('paper') : C('lt')) + '">' + esc(label) + '</text>');
      if (i < steps.length - 1) {
        out.push('<line x1="' + (x + w + 1) + '" y1="' + (h / 2 + 1) + '" x2="' + (x + gap - 1) + '" y2="' + (h / 2 + 1) +
          '" stroke="' + C('faint') + '" stroke-width="1"/>');
      }
    });
    return svg(out.join(''), { alt: 'wound track at ' + steps[reached],
      viewBox: '0 0 ' + (steps.length * gap - (gap - w)) + ' ' + (h + 2) });
  }

  /* ======================================================= MORALE TRACK */
  function moraleTrack(reached) {
    var steps = ['STEADY', 'SHAKEN', 'BROKEN'];
    var out = [], w = 52, h = 15, gap = 58;
    steps.forEach(function (label, i) {
      var on = i === reached;
      var x = i * gap;
      out.push('<rect x="' + x + '" y="1" width="' + w + '" height="' + h + '" rx="3.5" ' +
        'fill="' + (on ? (i === 2 ? C('harmfill') : C('act')) : 'none') + '" ' +
        'stroke="' + (on ? (i === 2 ? C('harm') : C('act')) : C('faint')) + '" stroke-width="1.3"/>');
      out.push('<text x="' + (x + w / 2) + '" y="' + (h / 2 + 4) + '" text-anchor="middle" font-size="7.5" ' +
        'font-weight="700" font-family="Helvetica,Arial,sans-serif" letter-spacing=".9" ' +
        'fill="' + (on ? C('paper') : C('lt')) + '">' + label + '</text>');
      if (i < 2) {
        out.push('<line x1="' + (x + w + 1) + '" y1="' + (h / 2 + 1) + '" x2="' + (x + gap - 1) + '" y2="' + (h / 2 + 1) +
          '" stroke="' + C('faint') + '" stroke-width="1" marker-end="url(#dxarrow)"/>');
      }
    });
    return svg(out.join(''), { alt: 'morale track at ' + steps[reached],
      viewBox: '0 0 ' + (3 * gap - (gap - w)) + ' ' + (h + 2) });
  }

  /* ============================================================== VERB ICONS */
  function verbIcon(verb) {
    var g;
    if (verb === 'MOVE') {
      g = '<rect x="4" y="14" width="13" height="13" rx="1" fill="none" stroke="' + C('lt') + '" ' +
          'stroke-width="1.4" stroke-dasharray="3 2.5"/>' +
          '<line x1="19" y1="20.5" x2="33" y2="20.5" stroke="' + C('act') + '" stroke-width="2" ' +
          'marker-end="url(#dxarrow)"/>' +
          '<rect x="35" y="14" width="13" height="13" rx="1" fill="' + C('ink') + '" stroke="' + C('ink') + '" stroke-width="1.4"/>';
    } else if (verb === 'ACTION') {
      g = '<rect x="6" y="13" width="15" height="15" rx="1" fill="' + C('ink') + '" stroke="' + C('ink') + '" stroke-width="1.4"/>' +
          '<path d="M23,20.5 L31,20.5" stroke="' + C('act') + '" stroke-width="2.4" marker-end="url(#dxarrow)"/>' +
          '<rect x="33" y="13" width="15" height="15" rx="1" fill="none" stroke="' + C('ink') + '" stroke-width="1.6"/>' +
          '<g stroke="' + C('act') + '" stroke-width="1.5" stroke-linecap="round">' +
          '<line x1="40.5" y1="9" x2="40.5" y2="4"/><line x1="46" y1="11" x2="49.5" y2="7.5"/>' +
          '<line x1="35" y1="11" x2="31.5" y2="7.5"/></g>';
    } else {
      g = '<rect x="8" y="14" width="15" height="15" rx="1" fill="' + C('ink') + '" stroke="' + C('ink') + '" stroke-width="1.4"/>' +
          '<rect x="27" y="10" width="16" height="20" rx="2" fill="none" stroke="' + C('act') + '" ' +
          'stroke-width="1.5" stroke-dasharray="3 2"/>' +
          '<circle cx="35" cy="20" r="5.4" fill="none" stroke="' + C('act') + '" stroke-width="1.3"/>' +
          '<path d="M35,16.6 L35,20 L37.6,21.6" stroke="' + C('act') + '" stroke-width="1.3" ' +
          'fill="none" stroke-linecap="round"/>';
    }
    return svg(g, { alt: verb + ' icon', viewBox: '0 0 54 34' });
  }

  /* ========================================================== PACKET CARD
   * The real card from packets_family.json — never a rules paragraph.
   * `reached` dims the lines you do NOT read (Model 2, discrete).       */
  function packetCard(p, reached) {
    var rows = p.grades.map(function (g) {
      var on = reached == null || g.grade === reached;
      var cls = 'dxg' + (reached != null ? (on ? ' on' : ' off') : '');
      return '<tr class="' + cls + '"><th>GRADE ' + g.grade + '</th><td>' +
        esc(g.effects.join(' · ')) + '</td></tr>';
    }).join('');
    return '<div class="dxcard">' +
      '<div class="dxcard-name">' + esc(p.name) + '</div>' +
      '<div class="dxcard-stats">' + p.dice + ' DICE · ' + p.success + '+ · ' +
        (p.range === 0 ? 'MELEE' : p.range + '"') + ' · ' + p.cost_ap + ' AP</div>' +
      '<table class="dxcard-grades">' + rows + '</table>' +
    '</div>';
  }

  return {
    mono: mono, isMono: function () { return MONO; }, bonusPill: bonusPill, twinPath: twinPath,
    sx: sx, sy: sy, U: U, FIELD: FIELD, footprint: footprint,
    svg: svg, base: base, board: board, wall: wall, objective: objective,
    movePath: movePath, strike: strike, bigArrow: bigArrow, reface: reface,
    apPips: apPips, dice: dice, woundTrack: woundTrack, moraleTrack: moraleTrack,
    verbIcon: verbIcon, packetCard: packetCard
  };
})();
