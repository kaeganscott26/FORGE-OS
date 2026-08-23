"use strict";
var __defProp = Object.defineProperty;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __export = (target, all) => {
  for (var name in all)
    __defProp(target, name, { get: all[name], enumerable: true });
};
var __copyProps = (to, from, except, desc) => {
  if (from && typeof from === "object" || typeof from === "function") {
    for (let key of __getOwnPropNames(from))
      if (!__hasOwnProp.call(to, key) && key !== except)
        __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
  }
  return to;
};
var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);

// src/main.ts
var main_exports = {};
__export(main_exports, {
  default: () => AgentcairnPlugin
});
module.exports = __toCommonJS(main_exports);
var import_obsidian2 = require("obsidian");

// src/view.ts
var import_obsidian = require("obsidian");

// src/query.ts
function facetValues(n, facet) {
  if (facet === "project") return n.project ? [n.project] : [];
  if (facet === "harness") return n.harness ? [n.harness] : [];
  if (facet === "tag") return n.tags;
  return [];
}
function buildGraph(notes, groupBy = "none") {
  var _a;
  const inSet = new Set(notes.map((n) => n.path));
  const seen = /* @__PURE__ */ new Set();
  const edges = [];
  const degree = /* @__PURE__ */ new Map();
  const addEdge = (a2, b) => {
    var _a2, _b;
    const key = [a2, b].sort().join(" ");
    if (seen.has(key)) return;
    seen.add(key);
    edges.push({ source: a2, target: b });
    degree.set(a2, ((_a2 = degree.get(a2)) != null ? _a2 : 0) + 1);
    degree.set(b, ((_b = degree.get(b)) != null ? _b : 0) + 1);
  };
  for (const n of notes) {
    for (const t of n.links) {
      if (t === n.path || !inSet.has(t)) continue;
      addEdge(n.path, t);
    }
  }
  const hubCount = /* @__PURE__ */ new Map();
  if (groupBy !== "none") {
    for (const n of notes) {
      for (const value of new Set(facetValues(n, groupBy))) {
        const id = `hub:${groupBy}:${value}`;
        addEdge(n.path, id);
        const h = (_a = hubCount.get(id)) != null ? _a : { value, count: 0 };
        h.count += 1;
        hubCount.set(id, h);
      }
    }
  }
  const hubs = [...hubCount.entries()].map(([id, h]) => ({ id, facet: groupBy, value: h.value, count: h.count }));
  const isolated = new Set(notes.map((n) => n.path).filter((p) => !degree.get(p)));
  return { nodes: notes, edges, isolated, hubs };
}
function filterNotes(notes, c2) {
  var _a;
  const q = (_a = c2.query) == null ? void 0 : _a.trim().toLowerCase();
  return notes.filter((n) => {
    if (c2.project && n.project !== c2.project) return false;
    if (c2.harness && n.harness !== c2.harness) return false;
    if (c2.currency && n.currency !== c2.currency) return false;
    if (c2.tag && !n.tags.includes(c2.tag)) return false;
    if (q) {
      const hay = `${n.title} ${n.tags.join(" ")} ${n.path}`.toLowerCase();
      if (!hay.includes(q)) return false;
    }
    return true;
  });
}
function sortNotes(notes, key) {
  const copy = [...notes];
  if (key === "newest") {
    copy.sort((a2, b) => (b.created ? Date.parse(b.created) : -Infinity) - (a2.created ? Date.parse(a2.created) : -Infinity));
  } else {
    copy.sort((a2, b) => {
      var _a, _b;
      return ((_a = b.importance) != null ? _a : -Infinity) - ((_b = a2.importance) != null ? _b : -Infinity);
    });
  }
  return copy;
}

// node_modules/d3-force/src/center.js
function center_default(x2, y2) {
  var nodes, strength = 1;
  if (x2 == null) x2 = 0;
  if (y2 == null) y2 = 0;
  function force() {
    var i, n = nodes.length, node, sx = 0, sy = 0;
    for (i = 0; i < n; ++i) {
      node = nodes[i], sx += node.x, sy += node.y;
    }
    for (sx = (sx / n - x2) * strength, sy = (sy / n - y2) * strength, i = 0; i < n; ++i) {
      node = nodes[i], node.x -= sx, node.y -= sy;
    }
  }
  force.initialize = function(_) {
    nodes = _;
  };
  force.x = function(_) {
    return arguments.length ? (x2 = +_, force) : x2;
  };
  force.y = function(_) {
    return arguments.length ? (y2 = +_, force) : y2;
  };
  force.strength = function(_) {
    return arguments.length ? (strength = +_, force) : strength;
  };
  return force;
}

// node_modules/d3-quadtree/src/add.js
function add_default(d) {
  const x2 = +this._x.call(null, d), y2 = +this._y.call(null, d);
  return add(this.cover(x2, y2), x2, y2, d);
}
function add(tree, x2, y2, d) {
  if (isNaN(x2) || isNaN(y2)) return tree;
  var parent, node = tree._root, leaf = { data: d }, x0 = tree._x0, y0 = tree._y0, x1 = tree._x1, y1 = tree._y1, xm, ym, xp, yp, right, bottom, i, j;
  if (!node) return tree._root = leaf, tree;
  while (node.length) {
    if (right = x2 >= (xm = (x0 + x1) / 2)) x0 = xm;
    else x1 = xm;
    if (bottom = y2 >= (ym = (y0 + y1) / 2)) y0 = ym;
    else y1 = ym;
    if (parent = node, !(node = node[i = bottom << 1 | right])) return parent[i] = leaf, tree;
  }
  xp = +tree._x.call(null, node.data);
  yp = +tree._y.call(null, node.data);
  if (x2 === xp && y2 === yp) return leaf.next = node, parent ? parent[i] = leaf : tree._root = leaf, tree;
  do {
    parent = parent ? parent[i] = new Array(4) : tree._root = new Array(4);
    if (right = x2 >= (xm = (x0 + x1) / 2)) x0 = xm;
    else x1 = xm;
    if (bottom = y2 >= (ym = (y0 + y1) / 2)) y0 = ym;
    else y1 = ym;
  } while ((i = bottom << 1 | right) === (j = (yp >= ym) << 1 | xp >= xm));
  return parent[j] = node, parent[i] = leaf, tree;
}
function addAll(data) {
  var d, i, n = data.length, x2, y2, xz = new Array(n), yz = new Array(n), x0 = Infinity, y0 = Infinity, x1 = -Infinity, y1 = -Infinity;
  for (i = 0; i < n; ++i) {
    if (isNaN(x2 = +this._x.call(null, d = data[i])) || isNaN(y2 = +this._y.call(null, d))) continue;
    xz[i] = x2;
    yz[i] = y2;
    if (x2 < x0) x0 = x2;
    if (x2 > x1) x1 = x2;
    if (y2 < y0) y0 = y2;
    if (y2 > y1) y1 = y2;
  }
  if (x0 > x1 || y0 > y1) return this;
  this.cover(x0, y0).cover(x1, y1);
  for (i = 0; i < n; ++i) {
    add(this, xz[i], yz[i], data[i]);
  }
  return this;
}

// node_modules/d3-quadtree/src/cover.js
function cover_default(x2, y2) {
  if (isNaN(x2 = +x2) || isNaN(y2 = +y2)) return this;
  var x0 = this._x0, y0 = this._y0, x1 = this._x1, y1 = this._y1;
  if (isNaN(x0)) {
    x1 = (x0 = Math.floor(x2)) + 1;
    y1 = (y0 = Math.floor(y2)) + 1;
  } else {
    var z = x1 - x0 || 1, node = this._root, parent, i;
    while (x0 > x2 || x2 >= x1 || y0 > y2 || y2 >= y1) {
      i = (y2 < y0) << 1 | x2 < x0;
      parent = new Array(4), parent[i] = node, node = parent, z *= 2;
      switch (i) {
        case 0:
          x1 = x0 + z, y1 = y0 + z;
          break;
        case 1:
          x0 = x1 - z, y1 = y0 + z;
          break;
        case 2:
          x1 = x0 + z, y0 = y1 - z;
          break;
        case 3:
          x0 = x1 - z, y0 = y1 - z;
          break;
      }
    }
    if (this._root && this._root.length) this._root = node;
  }
  this._x0 = x0;
  this._y0 = y0;
  this._x1 = x1;
  this._y1 = y1;
  return this;
}

// node_modules/d3-quadtree/src/data.js
function data_default() {
  var data = [];
  this.visit(function(node) {
    if (!node.length) do
      data.push(node.data);
    while (node = node.next);
  });
  return data;
}

// node_modules/d3-quadtree/src/extent.js
function extent_default(_) {
  return arguments.length ? this.cover(+_[0][0], +_[0][1]).cover(+_[1][0], +_[1][1]) : isNaN(this._x0) ? void 0 : [[this._x0, this._y0], [this._x1, this._y1]];
}

// node_modules/d3-quadtree/src/quad.js
function quad_default(node, x0, y0, x1, y1) {
  this.node = node;
  this.x0 = x0;
  this.y0 = y0;
  this.x1 = x1;
  this.y1 = y1;
}

// node_modules/d3-quadtree/src/find.js
function find_default(x2, y2, radius) {
  var data, x0 = this._x0, y0 = this._y0, x1, y1, x22, y22, x3 = this._x1, y3 = this._y1, quads = [], node = this._root, q, i;
  if (node) quads.push(new quad_default(node, x0, y0, x3, y3));
  if (radius == null) radius = Infinity;
  else {
    x0 = x2 - radius, y0 = y2 - radius;
    x3 = x2 + radius, y3 = y2 + radius;
    radius *= radius;
  }
  while (q = quads.pop()) {
    if (!(node = q.node) || (x1 = q.x0) > x3 || (y1 = q.y0) > y3 || (x22 = q.x1) < x0 || (y22 = q.y1) < y0) continue;
    if (node.length) {
      var xm = (x1 + x22) / 2, ym = (y1 + y22) / 2;
      quads.push(
        new quad_default(node[3], xm, ym, x22, y22),
        new quad_default(node[2], x1, ym, xm, y22),
        new quad_default(node[1], xm, y1, x22, ym),
        new quad_default(node[0], x1, y1, xm, ym)
      );
      if (i = (y2 >= ym) << 1 | x2 >= xm) {
        q = quads[quads.length - 1];
        quads[quads.length - 1] = quads[quads.length - 1 - i];
        quads[quads.length - 1 - i] = q;
      }
    } else {
      var dx = x2 - +this._x.call(null, node.data), dy = y2 - +this._y.call(null, node.data), d2 = dx * dx + dy * dy;
      if (d2 < radius) {
        var d = Math.sqrt(radius = d2);
        x0 = x2 - d, y0 = y2 - d;
        x3 = x2 + d, y3 = y2 + d;
        data = node.data;
      }
    }
  }
  return data;
}

// node_modules/d3-quadtree/src/remove.js
function remove_default(d) {
  if (isNaN(x2 = +this._x.call(null, d)) || isNaN(y2 = +this._y.call(null, d))) return this;
  var parent, node = this._root, retainer, previous, next, x0 = this._x0, y0 = this._y0, x1 = this._x1, y1 = this._y1, x2, y2, xm, ym, right, bottom, i, j;
  if (!node) return this;
  if (node.length) while (true) {
    if (right = x2 >= (xm = (x0 + x1) / 2)) x0 = xm;
    else x1 = xm;
    if (bottom = y2 >= (ym = (y0 + y1) / 2)) y0 = ym;
    else y1 = ym;
    if (!(parent = node, node = node[i = bottom << 1 | right])) return this;
    if (!node.length) break;
    if (parent[i + 1 & 3] || parent[i + 2 & 3] || parent[i + 3 & 3]) retainer = parent, j = i;
  }
  while (node.data !== d) if (!(previous = node, node = node.next)) return this;
  if (next = node.next) delete node.next;
  if (previous) return next ? previous.next = next : delete previous.next, this;
  if (!parent) return this._root = next, this;
  next ? parent[i] = next : delete parent[i];
  if ((node = parent[0] || parent[1] || parent[2] || parent[3]) && node === (parent[3] || parent[2] || parent[1] || parent[0]) && !node.length) {
    if (retainer) retainer[j] = node;
    else this._root = node;
  }
  return this;
}
function removeAll(data) {
  for (var i = 0, n = data.length; i < n; ++i) this.remove(data[i]);
  return this;
}

// node_modules/d3-quadtree/src/root.js
function root_default() {
  return this._root;
}

// node_modules/d3-quadtree/src/size.js
function size_default() {
  var size = 0;
  this.visit(function(node) {
    if (!node.length) do
      ++size;
    while (node = node.next);
  });
  return size;
}

// node_modules/d3-quadtree/src/visit.js
function visit_default(callback) {
  var quads = [], q, node = this._root, child, x0, y0, x1, y1;
  if (node) quads.push(new quad_default(node, this._x0, this._y0, this._x1, this._y1));
  while (q = quads.pop()) {
    if (!callback(node = q.node, x0 = q.x0, y0 = q.y0, x1 = q.x1, y1 = q.y1) && node.length) {
      var xm = (x0 + x1) / 2, ym = (y0 + y1) / 2;
      if (child = node[3]) quads.push(new quad_default(child, xm, ym, x1, y1));
      if (child = node[2]) quads.push(new quad_default(child, x0, ym, xm, y1));
      if (child = node[1]) quads.push(new quad_default(child, xm, y0, x1, ym));
      if (child = node[0]) quads.push(new quad_default(child, x0, y0, xm, ym));
    }
  }
  return this;
}

// node_modules/d3-quadtree/src/visitAfter.js
function visitAfter_default(callback) {
  var quads = [], next = [], q;
  if (this._root) quads.push(new quad_default(this._root, this._x0, this._y0, this._x1, this._y1));
  while (q = quads.pop()) {
    var node = q.node;
    if (node.length) {
      var child, x0 = q.x0, y0 = q.y0, x1 = q.x1, y1 = q.y1, xm = (x0 + x1) / 2, ym = (y0 + y1) / 2;
      if (child = node[0]) quads.push(new quad_default(child, x0, y0, xm, ym));
      if (child = node[1]) quads.push(new quad_default(child, xm, y0, x1, ym));
      if (child = node[2]) quads.push(new quad_default(child, x0, ym, xm, y1));
      if (child = node[3]) quads.push(new quad_default(child, xm, ym, x1, y1));
    }
    next.push(q);
  }
  while (q = next.pop()) {
    callback(q.node, q.x0, q.y0, q.x1, q.y1);
  }
  return this;
}

// node_modules/d3-quadtree/src/x.js
function defaultX(d) {
  return d[0];
}
function x_default(_) {
  return arguments.length ? (this._x = _, this) : this._x;
}

// node_modules/d3-quadtree/src/y.js
function defaultY(d) {
  return d[1];
}
function y_default(_) {
  return arguments.length ? (this._y = _, this) : this._y;
}

// node_modules/d3-quadtree/src/quadtree.js
function quadtree(nodes, x2, y2) {
  var tree = new Quadtree(x2 == null ? defaultX : x2, y2 == null ? defaultY : y2, NaN, NaN, NaN, NaN);
  return nodes == null ? tree : tree.addAll(nodes);
}
function Quadtree(x2, y2, x0, y0, x1, y1) {
  this._x = x2;
  this._y = y2;
  this._x0 = x0;
  this._y0 = y0;
  this._x1 = x1;
  this._y1 = y1;
  this._root = void 0;
}
function leaf_copy(leaf) {
  var copy = { data: leaf.data }, next = copy;
  while (leaf = leaf.next) next = next.next = { data: leaf.data };
  return copy;
}
var treeProto = quadtree.prototype = Quadtree.prototype;
treeProto.copy = function() {
  var copy = new Quadtree(this._x, this._y, this._x0, this._y0, this._x1, this._y1), node = this._root, nodes, child;
  if (!node) return copy;
  if (!node.length) return copy._root = leaf_copy(node), copy;
  nodes = [{ source: node, target: copy._root = new Array(4) }];
  while (node = nodes.pop()) {
    for (var i = 0; i < 4; ++i) {
      if (child = node.source[i]) {
        if (child.length) nodes.push({ source: child, target: node.target[i] = new Array(4) });
        else node.target[i] = leaf_copy(child);
      }
    }
  }
  return copy;
};
treeProto.add = add_default;
treeProto.addAll = addAll;
treeProto.cover = cover_default;
treeProto.data = data_default;
treeProto.extent = extent_default;
treeProto.find = find_default;
treeProto.remove = remove_default;
treeProto.removeAll = removeAll;
treeProto.root = root_default;
treeProto.size = size_default;
treeProto.visit = visit_default;
treeProto.visitAfter = visitAfter_default;
treeProto.x = x_default;
treeProto.y = y_default;

// node_modules/d3-force/src/constant.js
function constant_default(x2) {
  return function() {
    return x2;
  };
}

// node_modules/d3-force/src/jiggle.js
function jiggle_default(random) {
  return (random() - 0.5) * 1e-6;
}

// node_modules/d3-force/src/link.js
function index(d) {
  return d.index;
}
function find(nodeById, nodeId) {
  var node = nodeById.get(nodeId);
  if (!node) throw new Error("node not found: " + nodeId);
  return node;
}
function link_default(links) {
  var id = index, strength = defaultStrength, strengths, distance = constant_default(30), distances, nodes, count, bias, random, iterations = 1;
  if (links == null) links = [];
  function defaultStrength(link) {
    return 1 / Math.min(count[link.source.index], count[link.target.index]);
  }
  function force(alpha) {
    for (var k = 0, n = links.length; k < iterations; ++k) {
      for (var i = 0, link, source, target, x2, y2, l, b; i < n; ++i) {
        link = links[i], source = link.source, target = link.target;
        x2 = target.x + target.vx - source.x - source.vx || jiggle_default(random);
        y2 = target.y + target.vy - source.y - source.vy || jiggle_default(random);
        l = Math.sqrt(x2 * x2 + y2 * y2);
        l = (l - distances[i]) / l * alpha * strengths[i];
        x2 *= l, y2 *= l;
        target.vx -= x2 * (b = bias[i]);
        target.vy -= y2 * b;
        source.vx += x2 * (b = 1 - b);
        source.vy += y2 * b;
      }
    }
  }
  function initialize() {
    if (!nodes) return;
    var i, n = nodes.length, m2 = links.length, nodeById = new Map(nodes.map((d, i2) => [id(d, i2, nodes), d])), link;
    for (i = 0, count = new Array(n); i < m2; ++i) {
      link = links[i], link.index = i;
      if (typeof link.source !== "object") link.source = find(nodeById, link.source);
      if (typeof link.target !== "object") link.target = find(nodeById, link.target);
      count[link.source.index] = (count[link.source.index] || 0) + 1;
      count[link.target.index] = (count[link.target.index] || 0) + 1;
    }
    for (i = 0, bias = new Array(m2); i < m2; ++i) {
      link = links[i], bias[i] = count[link.source.index] / (count[link.source.index] + count[link.target.index]);
    }
    strengths = new Array(m2), initializeStrength();
    distances = new Array(m2), initializeDistance();
  }
  function initializeStrength() {
    if (!nodes) return;
    for (var i = 0, n = links.length; i < n; ++i) {
      strengths[i] = +strength(links[i], i, links);
    }
  }
  function initializeDistance() {
    if (!nodes) return;
    for (var i = 0, n = links.length; i < n; ++i) {
      distances[i] = +distance(links[i], i, links);
    }
  }
  force.initialize = function(_nodes, _random) {
    nodes = _nodes;
    random = _random;
    initialize();
  };
  force.links = function(_) {
    return arguments.length ? (links = _, initialize(), force) : links;
  };
  force.id = function(_) {
    return arguments.length ? (id = _, force) : id;
  };
  force.iterations = function(_) {
    return arguments.length ? (iterations = +_, force) : iterations;
  };
  force.strength = function(_) {
    return arguments.length ? (strength = typeof _ === "function" ? _ : constant_default(+_), initializeStrength(), force) : strength;
  };
  force.distance = function(_) {
    return arguments.length ? (distance = typeof _ === "function" ? _ : constant_default(+_), initializeDistance(), force) : distance;
  };
  return force;
}

// node_modules/d3-dispatch/src/dispatch.js
var noop = { value: () => {
} };
function dispatch() {
  for (var i = 0, n = arguments.length, _ = {}, t; i < n; ++i) {
    if (!(t = arguments[i] + "") || t in _ || /[\s.]/.test(t)) throw new Error("illegal type: " + t);
    _[t] = [];
  }
  return new Dispatch(_);
}
function Dispatch(_) {
  this._ = _;
}
function parseTypenames(typenames, types) {
  return typenames.trim().split(/^|\s+/).map(function(t) {
    var name = "", i = t.indexOf(".");
    if (i >= 0) name = t.slice(i + 1), t = t.slice(0, i);
    if (t && !types.hasOwnProperty(t)) throw new Error("unknown type: " + t);
    return { type: t, name };
  });
}
Dispatch.prototype = dispatch.prototype = {
  constructor: Dispatch,
  on: function(typename, callback) {
    var _ = this._, T = parseTypenames(typename + "", _), t, i = -1, n = T.length;
    if (arguments.length < 2) {
      while (++i < n) if ((t = (typename = T[i]).type) && (t = get(_[t], typename.name))) return t;
      return;
    }
    if (callback != null && typeof callback !== "function") throw new Error("invalid callback: " + callback);
    while (++i < n) {
      if (t = (typename = T[i]).type) _[t] = set(_[t], typename.name, callback);
      else if (callback == null) for (t in _) _[t] = set(_[t], typename.name, null);
    }
    return this;
  },
  copy: function() {
    var copy = {}, _ = this._;
    for (var t in _) copy[t] = _[t].slice();
    return new Dispatch(copy);
  },
  call: function(type, that) {
    if ((n = arguments.length - 2) > 0) for (var args = new Array(n), i = 0, n, t; i < n; ++i) args[i] = arguments[i + 2];
    if (!this._.hasOwnProperty(type)) throw new Error("unknown type: " + type);
    for (t = this._[type], i = 0, n = t.length; i < n; ++i) t[i].value.apply(that, args);
  },
  apply: function(type, that, args) {
    if (!this._.hasOwnProperty(type)) throw new Error("unknown type: " + type);
    for (var t = this._[type], i = 0, n = t.length; i < n; ++i) t[i].value.apply(that, args);
  }
};
function get(type, name) {
  for (var i = 0, n = type.length, c2; i < n; ++i) {
    if ((c2 = type[i]).name === name) {
      return c2.value;
    }
  }
}
function set(type, name, callback) {
  for (var i = 0, n = type.length; i < n; ++i) {
    if (type[i].name === name) {
      type[i] = noop, type = type.slice(0, i).concat(type.slice(i + 1));
      break;
    }
  }
  if (callback != null) type.push({ name, value: callback });
  return type;
}
var dispatch_default = dispatch;

// node_modules/d3-timer/src/timer.js
var frame = 0;
var timeout = 0;
var interval = 0;
var pokeDelay = 1e3;
var taskHead;
var taskTail;
var clockLast = 0;
var clockNow = 0;
var clockSkew = 0;
var clock = typeof performance === "object" && performance.now ? performance : Date;
var setFrame = typeof window === "object" && window.requestAnimationFrame ? window.requestAnimationFrame.bind(window) : function(f) {
  setTimeout(f, 17);
};
function now() {
  return clockNow || (setFrame(clearNow), clockNow = clock.now() + clockSkew);
}
function clearNow() {
  clockNow = 0;
}
function Timer() {
  this._call = this._time = this._next = null;
}
Timer.prototype = timer.prototype = {
  constructor: Timer,
  restart: function(callback, delay, time) {
    if (typeof callback !== "function") throw new TypeError("callback is not a function");
    time = (time == null ? now() : +time) + (delay == null ? 0 : +delay);
    if (!this._next && taskTail !== this) {
      if (taskTail) taskTail._next = this;
      else taskHead = this;
      taskTail = this;
    }
    this._call = callback;
    this._time = time;
    sleep();
  },
  stop: function() {
    if (this._call) {
      this._call = null;
      this._time = Infinity;
      sleep();
    }
  }
};
function timer(callback, delay, time) {
  var t = new Timer();
  t.restart(callback, delay, time);
  return t;
}
function timerFlush() {
  now();
  ++frame;
  var t = taskHead, e;
  while (t) {
    if ((e = clockNow - t._time) >= 0) t._call.call(void 0, e);
    t = t._next;
  }
  --frame;
}
function wake() {
  clockNow = (clockLast = clock.now()) + clockSkew;
  frame = timeout = 0;
  try {
    timerFlush();
  } finally {
    frame = 0;
    nap();
    clockNow = 0;
  }
}
function poke() {
  var now2 = clock.now(), delay = now2 - clockLast;
  if (delay > pokeDelay) clockSkew -= delay, clockLast = now2;
}
function nap() {
  var t0, t1 = taskHead, t2, time = Infinity;
  while (t1) {
    if (t1._call) {
      if (time > t1._time) time = t1._time;
      t0 = t1, t1 = t1._next;
    } else {
      t2 = t1._next, t1._next = null;
      t1 = t0 ? t0._next = t2 : taskHead = t2;
    }
  }
  taskTail = t0;
  sleep(time);
}
function sleep(time) {
  if (frame) return;
  if (timeout) timeout = clearTimeout(timeout);
  var delay = time - clockNow;
  if (delay > 24) {
    if (time < Infinity) timeout = setTimeout(wake, time - clock.now() - clockSkew);
    if (interval) interval = clearInterval(interval);
  } else {
    if (!interval) clockLast = clock.now(), interval = setInterval(poke, pokeDelay);
    frame = 1, setFrame(wake);
  }
}

// node_modules/d3-force/src/lcg.js
var a = 1664525;
var c = 1013904223;
var m = 4294967296;
function lcg_default() {
  let s = 1;
  return () => (s = (a * s + c) % m) / m;
}

// node_modules/d3-force/src/simulation.js
function x(d) {
  return d.x;
}
function y(d) {
  return d.y;
}
var initialRadius = 10;
var initialAngle = Math.PI * (3 - Math.sqrt(5));
function simulation_default(nodes) {
  var simulation, alpha = 1, alphaMin = 1e-3, alphaDecay = 1 - Math.pow(alphaMin, 1 / 300), alphaTarget = 0, velocityDecay = 0.6, forces = /* @__PURE__ */ new Map(), stepper = timer(step), event = dispatch_default("tick", "end"), random = lcg_default();
  if (nodes == null) nodes = [];
  function step() {
    tick();
    event.call("tick", simulation);
    if (alpha < alphaMin) {
      stepper.stop();
      event.call("end", simulation);
    }
  }
  function tick(iterations) {
    var i, n = nodes.length, node;
    if (iterations === void 0) iterations = 1;
    for (var k = 0; k < iterations; ++k) {
      alpha += (alphaTarget - alpha) * alphaDecay;
      forces.forEach(function(force) {
        force(alpha);
      });
      for (i = 0; i < n; ++i) {
        node = nodes[i];
        if (node.fx == null) node.x += node.vx *= velocityDecay;
        else node.x = node.fx, node.vx = 0;
        if (node.fy == null) node.y += node.vy *= velocityDecay;
        else node.y = node.fy, node.vy = 0;
      }
    }
    return simulation;
  }
  function initializeNodes() {
    for (var i = 0, n = nodes.length, node; i < n; ++i) {
      node = nodes[i], node.index = i;
      if (node.fx != null) node.x = node.fx;
      if (node.fy != null) node.y = node.fy;
      if (isNaN(node.x) || isNaN(node.y)) {
        var radius = initialRadius * Math.sqrt(0.5 + i), angle = i * initialAngle;
        node.x = radius * Math.cos(angle);
        node.y = radius * Math.sin(angle);
      }
      if (isNaN(node.vx) || isNaN(node.vy)) {
        node.vx = node.vy = 0;
      }
    }
  }
  function initializeForce(force) {
    if (force.initialize) force.initialize(nodes, random);
    return force;
  }
  initializeNodes();
  return simulation = {
    tick,
    restart: function() {
      return stepper.restart(step), simulation;
    },
    stop: function() {
      return stepper.stop(), simulation;
    },
    nodes: function(_) {
      return arguments.length ? (nodes = _, initializeNodes(), forces.forEach(initializeForce), simulation) : nodes;
    },
    alpha: function(_) {
      return arguments.length ? (alpha = +_, simulation) : alpha;
    },
    alphaMin: function(_) {
      return arguments.length ? (alphaMin = +_, simulation) : alphaMin;
    },
    alphaDecay: function(_) {
      return arguments.length ? (alphaDecay = +_, simulation) : +alphaDecay;
    },
    alphaTarget: function(_) {
      return arguments.length ? (alphaTarget = +_, simulation) : alphaTarget;
    },
    velocityDecay: function(_) {
      return arguments.length ? (velocityDecay = 1 - _, simulation) : 1 - velocityDecay;
    },
    randomSource: function(_) {
      return arguments.length ? (random = _, forces.forEach(initializeForce), simulation) : random;
    },
    force: function(name, _) {
      return arguments.length > 1 ? (_ == null ? forces.delete(name) : forces.set(name, initializeForce(_)), simulation) : forces.get(name);
    },
    find: function(x2, y2, radius) {
      var i = 0, n = nodes.length, dx, dy, d2, node, closest;
      if (radius == null) radius = Infinity;
      else radius *= radius;
      for (i = 0; i < n; ++i) {
        node = nodes[i];
        dx = x2 - node.x;
        dy = y2 - node.y;
        d2 = dx * dx + dy * dy;
        if (d2 < radius) closest = node, radius = d2;
      }
      return closest;
    },
    on: function(name, _) {
      return arguments.length > 1 ? (event.on(name, _), simulation) : event.on(name);
    }
  };
}

// node_modules/d3-force/src/manyBody.js
function manyBody_default() {
  var nodes, node, random, alpha, strength = constant_default(-30), strengths, distanceMin2 = 1, distanceMax2 = Infinity, theta2 = 0.81;
  function force(_) {
    var i, n = nodes.length, tree = quadtree(nodes, x, y).visitAfter(accumulate);
    for (alpha = _, i = 0; i < n; ++i) node = nodes[i], tree.visit(apply);
  }
  function initialize() {
    if (!nodes) return;
    var i, n = nodes.length, node2;
    strengths = new Array(n);
    for (i = 0; i < n; ++i) node2 = nodes[i], strengths[node2.index] = +strength(node2, i, nodes);
  }
  function accumulate(quad) {
    var strength2 = 0, q, c2, weight = 0, x2, y2, i;
    if (quad.length) {
      for (x2 = y2 = i = 0; i < 4; ++i) {
        if ((q = quad[i]) && (c2 = Math.abs(q.value))) {
          strength2 += q.value, weight += c2, x2 += c2 * q.x, y2 += c2 * q.y;
        }
      }
      quad.x = x2 / weight;
      quad.y = y2 / weight;
    } else {
      q = quad;
      q.x = q.data.x;
      q.y = q.data.y;
      do
        strength2 += strengths[q.data.index];
      while (q = q.next);
    }
    quad.value = strength2;
  }
  function apply(quad, x1, _, x2) {
    if (!quad.value) return true;
    var x3 = quad.x - node.x, y2 = quad.y - node.y, w = x2 - x1, l = x3 * x3 + y2 * y2;
    if (w * w / theta2 < l) {
      if (l < distanceMax2) {
        if (x3 === 0) x3 = jiggle_default(random), l += x3 * x3;
        if (y2 === 0) y2 = jiggle_default(random), l += y2 * y2;
        if (l < distanceMin2) l = Math.sqrt(distanceMin2 * l);
        node.vx += x3 * quad.value * alpha / l;
        node.vy += y2 * quad.value * alpha / l;
      }
      return true;
    } else if (quad.length || l >= distanceMax2) return;
    if (quad.data !== node || quad.next) {
      if (x3 === 0) x3 = jiggle_default(random), l += x3 * x3;
      if (y2 === 0) y2 = jiggle_default(random), l += y2 * y2;
      if (l < distanceMin2) l = Math.sqrt(distanceMin2 * l);
    }
    do
      if (quad.data !== node) {
        w = strengths[quad.data.index] * alpha / l;
        node.vx += x3 * w;
        node.vy += y2 * w;
      }
    while (quad = quad.next);
  }
  force.initialize = function(_nodes, _random) {
    nodes = _nodes;
    random = _random;
    initialize();
  };
  force.strength = function(_) {
    return arguments.length ? (strength = typeof _ === "function" ? _ : constant_default(+_), initialize(), force) : strength;
  };
  force.distanceMin = function(_) {
    return arguments.length ? (distanceMin2 = _ * _, force) : Math.sqrt(distanceMin2);
  };
  force.distanceMax = function(_) {
    return arguments.length ? (distanceMax2 = _ * _, force) : Math.sqrt(distanceMax2);
  };
  force.theta = function(_) {
    return arguments.length ? (theta2 = _ * _, force) : Math.sqrt(theta2);
  };
  return force;
}

// node_modules/d3-force/src/x.js
function x_default2(x2) {
  var strength = constant_default(0.1), nodes, strengths, xz;
  if (typeof x2 !== "function") x2 = constant_default(x2 == null ? 0 : +x2);
  function force(alpha) {
    for (var i = 0, n = nodes.length, node; i < n; ++i) {
      node = nodes[i], node.vx += (xz[i] - node.x) * strengths[i] * alpha;
    }
  }
  function initialize() {
    if (!nodes) return;
    var i, n = nodes.length;
    strengths = new Array(n);
    xz = new Array(n);
    for (i = 0; i < n; ++i) {
      strengths[i] = isNaN(xz[i] = +x2(nodes[i], i, nodes)) ? 0 : +strength(nodes[i], i, nodes);
    }
  }
  force.initialize = function(_) {
    nodes = _;
    initialize();
  };
  force.strength = function(_) {
    return arguments.length ? (strength = typeof _ === "function" ? _ : constant_default(+_), initialize(), force) : strength;
  };
  force.x = function(_) {
    return arguments.length ? (x2 = typeof _ === "function" ? _ : constant_default(+_), initialize(), force) : x2;
  };
  return force;
}

// node_modules/d3-force/src/y.js
function y_default2(y2) {
  var strength = constant_default(0.1), nodes, strengths, yz;
  if (typeof y2 !== "function") y2 = constant_default(y2 == null ? 0 : +y2);
  function force(alpha) {
    for (var i = 0, n = nodes.length, node; i < n; ++i) {
      node = nodes[i], node.vy += (yz[i] - node.y) * strengths[i] * alpha;
    }
  }
  function initialize() {
    if (!nodes) return;
    var i, n = nodes.length;
    strengths = new Array(n);
    yz = new Array(n);
    for (i = 0; i < n; ++i) {
      strengths[i] = isNaN(yz[i] = +y2(nodes[i], i, nodes)) ? 0 : +strength(nodes[i], i, nodes);
    }
  }
  force.initialize = function(_) {
    nodes = _;
    initialize();
  };
  force.strength = function(_) {
    return arguments.length ? (strength = typeof _ === "function" ? _ : constant_default(+_), initialize(), force) : strength;
  };
  force.y = function(_) {
    return arguments.length ? (y2 = typeof _ === "function" ? _ : constant_default(+_), initialize(), force) : y2;
  };
  return force;
}

// src/viz.ts
function projectColor(key) {
  if (!key) return "var(--text-muted)";
  let h = 0;
  for (let i = 0; i < key.length; i++) h = (h * 31 + key.charCodeAt(i)) % 360;
  return `hsl(${h}, 65%, 55%)`;
}
var R_MIN = 4;
var R_MAX = 10;
var R_DEFAULT = 6;
function nodeRadius(importance) {
  if (importance == null || Number.isNaN(importance)) return R_DEFAULT;
  const clamped = Math.max(0, Math.min(1, importance));
  return R_MIN + clamped * (R_MAX - R_MIN);
}
function currencyOpacity(c2) {
  return c2 === "current" ? 1 : 0.45;
}

// src/graph.ts
var NS = "http://www.w3.org/2000/svg";
var hubR = (count) => Math.min(22, 10 + Math.sqrt(count) * 2);
var hubFill = (h) => h.facet === "project" ? projectColor(h.value) : "var(--text-accent)";
function renderGraph(host, notes, opts) {
  host.empty();
  const MAX = 2e3;
  const used = notes.length > MAX ? notes.slice(0, MAX) : notes;
  if (notes.length > MAX) {
    const d = activeDocument.createElement("div");
    d.className = "ac-empty";
    d.textContent = `Showing first ${MAX} of ${notes.length} notes.`;
    host.appendChild(d);
  }
  const { edges, isolated, hubs } = buildGraph(used, opts.groupBy);
  const noteNodes = used.map((n) => ({ kind: "note", id: n.path, note: n, isolated: isolated.has(n.path) }));
  const hubNodes = hubs.map((h) => ({ kind: "hub", id: h.id, hub: h }));
  const allNodes = [...noteNodes, ...hubNodes];
  const byId = new Map(allNodes.map((n) => [n.id, n]));
  const links = edges.map((e) => {
    const source = byId.get(e.source);
    const target = byId.get(e.target);
    if (!source || !target) return null;
    return { source, target, isHubEdge: e.target.startsWith("hub:") || e.source.startsWith("hub:") };
  }).filter((l) => l !== null);
  const svg = activeDocument.createElementNS(NS, "svg");
  svg.setAttribute("class", "ac-graph");
  const w = host.clientWidth || 600, hgt = host.clientHeight || 400;
  svg.setAttribute("viewBox", `0 0 ${w} ${hgt}`);
  host.appendChild(svg);
  svg.addEventListener("click", (e) => {
    var _a;
    if (e.target === svg) (_a = opts.onBackgroundClick) == null ? void 0 : _a.call(opts);
  });
  const gLinks = activeDocument.createElementNS(NS, "g");
  const gNodes = activeDocument.createElementNS(NS, "g");
  svg.appendChild(gLinks);
  svg.appendChild(gNodes);
  const lineEls = links.map((l) => {
    const ln = activeDocument.createElementNS(NS, "line");
    ln.setAttribute("stroke", "var(--background-modifier-border)");
    if (l.isHubEdge) {
      ln.setAttribute("class", "ac-hub-edge");
    } else {
      const srcCurrency = l.source.kind === "note" ? l.source.note.currency : "current";
      const tgtCurrency = l.target.kind === "note" ? l.target.note.currency : "current";
      if (srcCurrency !== "current" || tgtCurrency !== "current") ln.setAttribute("stroke-dasharray", "3,3");
    }
    gLinks.appendChild(ln);
    return ln;
  });
  const circleEls = noteNodes.map((n) => {
    const c2 = activeDocument.createElementNS(NS, "circle");
    c2.setAttribute("r", String(nodeRadius(n.note.importance)));
    c2.setAttribute("fill", projectColor(n.note.project));
    const op = currencyOpacity(n.note.currency) * (n.isolated ? 0.5 : 1);
    c2.setAttribute("opacity", String(op));
    c2.addEventListener("click", () => opts.onNodeClick(n.note.path));
    const t = activeDocument.createElementNS(NS, "title");
    t.textContent = `${n.note.title}${n.note.project ? ` \xB7 ${n.note.project}` : ""}`;
    c2.appendChild(t);
    gNodes.appendChild(c2);
    return c2;
  });
  const hubEls = hubNodes.map((n) => {
    const c2 = activeDocument.createElementNS(NS, "circle");
    c2.setAttribute("r", String(hubR(n.hub.count)));
    c2.setAttribute("fill", hubFill(n.hub));
    c2.setAttribute("class", "ac-hub");
    c2.addEventListener("click", () => opts.onHubClick(n.hub.facet, n.hub.value));
    const t = activeDocument.createElementNS(NS, "title");
    t.textContent = `${n.hub.value} (${n.hub.count})`;
    c2.appendChild(t);
    gNodes.appendChild(c2);
    const lbl = activeDocument.createElementNS(NS, "text");
    lbl.setAttribute("class", "ac-hub-label");
    lbl.textContent = n.hub.value;
    gNodes.appendChild(lbl);
    return { circle: c2, label: lbl };
  });
  const sim = simulation_default(allNodes).force("link", link_default(links).distance(40)).force("charge", manyBody_default().strength(-80)).force("center", center_default(w / 2, hgt / 2)).force("xIso", x_default2((n) => n.kind === "note" && n.isolated ? w * 0.92 : w / 2).strength((n) => n.kind === "note" && n.isolated ? 0.3 : 0)).force("yIso", y_default2(() => hgt / 2).strength((n) => n.kind === "note" && n.isolated ? 0.05 : 0));
  sim.on("tick", () => {
    links.forEach((l, i) => {
      lineEls[i].setAttribute("x1", String(l.source.x));
      lineEls[i].setAttribute("y1", String(l.source.y));
      lineEls[i].setAttribute("x2", String(l.target.x));
      lineEls[i].setAttribute("y2", String(l.target.y));
    });
    noteNodes.forEach((n, i) => {
      circleEls[i].setAttribute("cx", String(n.x));
      circleEls[i].setAttribute("cy", String(n.y));
    });
    hubNodes.forEach((n, i) => {
      var _a, _b;
      const r = hubR(n.hub.count);
      hubEls[i].circle.setAttribute("cx", String(n.x));
      hubEls[i].circle.setAttribute("cy", String(n.y));
      hubEls[i].label.setAttribute("x", String(((_a = n.x) != null ? _a : 0) + r + 2));
      hubEls[i].label.setAttribute("y", String(((_b = n.y) != null ? _b : 0) + 4));
    });
  });
  renderLegend(host, used);
  return sim;
}
function renderLegend(host, notes) {
  const legend = activeDocument.createElement("div");
  legend.className = "ac-legend";
  const projects = [...new Set(notes.map((n) => n.project).filter((p) => !!p))].sort();
  for (const p of projects) {
    const row = activeDocument.createElement("div");
    row.className = "ac-legend-row";
    const sw = activeDocument.createElement("span");
    sw.className = "ac-swatch";
    sw.style.background = projectColor(p);
    row.appendChild(sw);
    row.appendChild(activeDocument.createTextNode(p));
    legend.appendChild(row);
  }
  const note = activeDocument.createElement("div");
  note.className = "ac-legend-note";
  note.textContent = "Dim = superseded/expired/isolated \xB7 edge = related memory";
  legend.appendChild(note);
  host.appendChild(legend);
}

// src/view.ts
var VIEW_TYPE_MEMORY = "agentcairn-memory";
var MemoryView = class extends import_obsidian.ItemView {
  constructor(leaf, plugin) {
    super(leaf);
    this.criteria = {};
    this.sort = "newest";
    this.mode = "list";
    this.groupBy = "none";
    this.selectedPath = null;
    this.timer = null;
    this.sim = null;
    this.plugin = plugin;
  }
  getViewType() {
    return VIEW_TYPE_MEMORY;
  }
  getDisplayText() {
    return "Agentcairn memory";
  }
  getIcon() {
    return "brain";
  }
  async onOpen() {
    this.registerEvent(this.app.workspace.on("active-leaf-change", () => {
      if (this.mode === "graph") this.refreshProvenance();
      else this.render();
    }));
    this.render();
  }
  async onClose() {
    var _a;
    (_a = this.sim) == null ? void 0 : _a.stop();
    this.sim = null;
  }
  scheduleRender() {
    if (this.timer) window.clearTimeout(this.timer);
    this.timer = window.setTimeout(() => this.render(), 200);
  }
  render() {
    var _a;
    (_a = this.sim) == null ? void 0 : _a.stop();
    this.sim = null;
    const root = this.containerEl.children[1];
    root.empty();
    root.addClass("agentcairn-memory");
    const all = this.plugin.buildModel();
    this.renderFilterBar(root, all);
    const shown = sortNotes(filterNotes(all, this.criteria), this.sort);
    if (this.selectedPath && !shown.some((n) => n.path === this.selectedPath)) this.selectedPath = null;
    const body = root.createDiv({ cls: "ac-body" });
    if (all.length === 0) body.createDiv({ cls: "ac-empty", text: "No agentcairn memories found in this vault." });
    else if (this.mode === "list") this.renderList(body, shown);
    else this.sim = renderGraph(body, shown, {
      groupBy: this.groupBy,
      onNodeClick: (path) => {
        this.selectedPath = path;
        this.plugin.openNote(path);
        this.refreshProvenance();
      },
      onHubClick: (facet, value) => {
        this.criteria[facet] = value;
        this.render();
      },
      onBackgroundClick: () => {
        this.selectedPath = null;
        this.refreshProvenance();
      }
    });
    this.renderProvenance(root);
  }
  renderFilterBar(root, all) {
    var _a;
    const bar = root.createDiv({ cls: "ac-filter" });
    const search = bar.createEl("input", { attr: { type: "text", placeholder: "Search\u2026" } });
    search.value = (_a = this.criteria.query) != null ? _a : "";
    search.oninput = () => {
      this.criteria.query = search.value;
      this.scheduleRender();
    };
    const uniq = (f) => [...new Set(all.map(f).filter((v) => !!v))].sort();
    this.dropdown(bar, "project", uniq((n) => n.project));
    this.dropdown(bar, "harness", uniq((n) => n.harness));
    const allTags = [...new Set(all.flatMap((n) => n.tags))].sort();
    this.dropdown(bar, "tag", allTags);
    this.dropdown(bar, "currency", ["current", "superseded", "expired", "not_yet_valid"]);
    const sortSel = bar.createEl("select");
    for (const k of ["newest", "importance"]) sortSel.createEl("option", { value: k, text: k });
    sortSel.value = this.sort;
    sortSel.onchange = () => {
      this.sort = sortSel.value;
      this.scheduleRender();
    };
    const groupSel = bar.createEl("select");
    for (const g of ["none", "project", "harness", "tag"]) {
      groupSel.createEl("option", { value: g, text: g === "none" ? "group: none" : `group: ${g}` });
    }
    groupSel.value = this.groupBy;
    groupSel.onchange = () => {
      this.groupBy = groupSel.value;
      this.render();
    };
    const toggle = bar.createEl("button", { text: this.mode === "list" ? "Graph" : "List" });
    toggle.onclick = () => {
      this.mode = this.mode === "list" ? "graph" : "list";
      this.selectedPath = null;
      this.render();
    };
  }
  dropdown(bar, key, opts) {
    var _a;
    const sel = bar.createEl("select");
    sel.createEl("option", { value: "", text: `${key}: all` });
    for (const o of opts) sel.createEl("option", { value: o, text: o });
    sel.value = (_a = this.criteria[key]) != null ? _a : "";
    sel.onchange = () => {
      this.criteria[key] = sel.value || void 0;
      this.scheduleRender();
    };
  }
  renderList(body, notes) {
    var _a;
    const list = body.createDiv({ cls: "ac-list" });
    for (const n of notes) {
      const row = list.createDiv({ cls: `ac-row ac-${n.currency}` });
      row.onclick = () => this.plugin.openNote(n.path);
      row.createDiv({ cls: "ac-title", text: n.title });
      const meta = [(_a = n.created) == null ? void 0 : _a.slice(0, 10), n.harness, n.project, n.importance != null ? `imp ${n.importance}` : null].filter(Boolean).join(" \xB7 ");
      row.createDiv({ cls: "ac-meta", text: meta });
      if (n.currency !== "current") row.createSpan({ cls: "ac-badge", text: n.currency });
    }
  }
  renderProvenance(root) {
    var _a, _b, _c, _d;
    (_a = root.querySelector(".ac-prov")) == null ? void 0 : _a.remove();
    const model = this.plugin.buildModel();
    const targetPath = (_c = this.selectedPath) != null ? _c : (_b = this.app.workspace.getActiveFile()) == null ? void 0 : _b.path;
    const note = targetPath ? model.find((n) => n.path === targetPath) : void 0;
    if (!note) return;
    const p = root.createDiv({ cls: "ac-prov" });
    p.createDiv({ cls: "ac-prov-h", text: this.selectedPath ? "selected" : "active note" });
    p.createDiv({ text: [note.project, note.harness, note.session && `session ${note.session}`].filter(Boolean).join(" \xB7 ") });
    p.createSpan({ cls: `ac-badge ac-${note.currency}`, text: note.currency });
    p.createDiv({ cls: "ac-prov-meta", text: [(_d = note.created) == null ? void 0 : _d.slice(0, 10), note.importance != null ? `imp ${note.importance}` : null].filter(Boolean).join(" \xB7 ") });
  }
  refreshProvenance() {
    const root = this.containerEl.children[1];
    this.renderProvenance(root);
  }
};

// src/model.ts
var str = (v) => typeof v === "string" && v ? v : void 0;
var num = (v) => typeof v === "number" && !Number.isNaN(v) ? v : void 0;
function parseDate(s) {
  if (!s) return void 0;
  const d = new Date(s);
  return Number.isNaN(d.getTime()) ? void 0 : d;
}
function computeCurrency(n, now2) {
  if (n.supersededBy) return "superseded";
  const vu = parseDate(n.validUntil);
  if (vu && now2.getTime() >= vu.getTime()) return "expired";
  const vf = parseDate(n.validFrom);
  if (vf && vf.getTime() > now2.getTime()) return "not_yet_valid";
  return "current";
}
function parseMemoryNote(fm, path, title, linkTargets, now2) {
  var _a;
  if ((fm == null ? void 0 : fm.type) !== "memory") return null;
  const tags = Array.isArray(fm.tags) ? fm.tags.filter((t) => typeof t === "string") : [];
  const source = str(fm.source);
  const m2 = source == null ? void 0 : source.match(/^memory:\/\/session\/(.+)$/);
  const base = { validFrom: str(fm.valid_from), validUntil: str(fm.valid_until), supersededBy: str(fm.superseded_by) };
  return {
    path,
    title: (_a = str(fm.title)) != null ? _a : title,
    project: str(fm.project),
    harness: str(fm.harness),
    session: m2 ? m2[1] : void 0,
    importance: num(fm.importance),
    created: str(fm.created),
    tags,
    ...base,
    currency: computeCurrency(base, now2),
    links: linkTargets
  };
}

// src/main.ts
var AgentcairnPlugin = class extends import_obsidian2.Plugin {
  async onload() {
    this.registerView(VIEW_TYPE_MEMORY, (leaf) => new MemoryView(leaf, this));
    this.addRibbonIcon("brain", "Agentcairn memory", () => this.activateView());
    this.addCommand({ id: "open-memory-view", name: "Open memory view", callback: () => this.activateView() });
    this.registerEvent(this.app.metadataCache.on("resolved", () => this.refreshViews()));
    this.registerEvent(this.app.metadataCache.on("changed", () => this.refreshViews()));
  }
  onunload() {
  }
  buildModel(now2 = /* @__PURE__ */ new Date()) {
    var _a, _b;
    const resolved = this.app.metadataCache.resolvedLinks;
    const out = [];
    for (const file of this.app.vault.getMarkdownFiles()) {
      const cache = this.app.metadataCache.getFileCache(file);
      const fm = (_a = cache == null ? void 0 : cache.frontmatter) != null ? _a : {};
      const linkTargets = Object.keys((_b = resolved[file.path]) != null ? _b : {});
      const note = parseMemoryNote(fm, file.path, file.basename, linkTargets, now2);
      if (note) out.push(note);
    }
    return out;
  }
  async activateView() {
    const { workspace } = this.app;
    let leaf = workspace.getLeavesOfType(VIEW_TYPE_MEMORY)[0];
    if (!leaf) {
      leaf = workspace.getRightLeaf(false);
      await leaf.setViewState({ type: VIEW_TYPE_MEMORY, active: true });
    }
    await workspace.revealLeaf(leaf);
  }
  refreshViews() {
    for (const leaf of this.app.workspace.getLeavesOfType(VIEW_TYPE_MEMORY)) leaf.view.scheduleRender();
  }
  openNote(path) {
    const file = this.app.vault.getAbstractFileByPath(path);
    if (file instanceof import_obsidian2.TFile) void this.app.workspace.getLeaf(false).openFile(file);
  }
};

/* nosourcemap */