local core = require "core"
local common = require "core.common"
local config = require "core.config"
local command = require "core.command"
local keymap = require "core.keymap"
local style = require "core.style"
local Object = require "core.object"
local RootView = require "core.rootview"

local border_width = 1
local divider_width = 1
local DIVIDER = {}

local MenuContext = Object:extend()

MenuContext.DIVIDER = DIVIDER

function MenuContext:new()
  self.itemset = {}
  self.show_context_menu = false
  self.selected = -1
  self.height = 0
  self.position = { x = 0, y = 0 }
end

local function get_item_size(item)
  local lw, lh
  if item == DIVIDER then
    lw = 0
    lh = divider_width
  else
    lw = style.font:get_width(item.text)
    if item.info then
      lw = lw + style.padding.x + style.font:get_width(item.info)
    end
    lh = style.font:get_height() + style.padding.y
  end
  return lw, lh
end

function MenuContext:register(predicate, items)
  if type(predicate) == "string" then
    predicate = require(predicate)
  end
  if type(predicate) == "table" then
    local class = predicate
    predicate = function() return core.active_view:is(class) end
  end
  
  local width, height = 0, 0 --precalculate the size of context menucontext
  for i, item in ipairs(items) do
    if item ~= DIVIDER then
      item.info = keymap.reverse_map[item.command]
    end
    local lw, lh = get_item_size(item)
    width = math.max(width, lw)
    height = height + lh
  end
  width = width + style.padding.x * 2
  items.width, items.height = width, height
  table.insert(self.itemset, { predicate = predicate, items = items })
end

function MenuContext:show(x, y)
  self.items = nil
  for _, items in ipairs(self.itemset) do
    if items.predicate(x, y) then
      self.items = items.items
      break
    end
  end
    
  if self.items then
    local w, h = self.items.width, self.items.height

    -- by default the box is opened on the right and below
    if x + w >= core.root_view.size.x then
      x = x - w
    end
    if y + h >= core.root_view.size.y then
      y = y - h
    end

    self.position.x, self.position.y = x, y
    self.show_context_menu = true
    return true
  end
  return false
end

function MenuContext:hide()
  self.show_context_menu = false
  self.items = nil
  self.selected = -1
  self.height = 0
end

function MenuContext:each_item()
  local x, y, w = self.position.x, self.position.y, self.items.width
  local oy = y
  return coroutine.wrap(function()
    for i, item in ipairs(self.items) do
      local _, lh = get_item_size(item)
      if y - oy > self.height then break end
      coroutine.yield(i, item, x, y, w, lh)
      y = y + lh
    end
  end)
end

function MenuContext:on_mouse_moved(px, py)
  if not self.show_context_menu then return end

  for i, item, x, y, w, h in self:each_item() do
    if px > x and px <= x + w and py > y and py <= y + h then
      system.set_cursor("arrow")
      self.selected = i
      return true
    end
  end
  self.selected = -1
  return true
end

function MenuContext:on_selected(item)
  if type(item.command) == "string" then
    command.perform(item.command)
  else
    item.command()
  end
end

function MenuContext:on_mouse_pressed(button, x, y, clicks)
  local selected = (self.items or {})[self.selected]
  local caught = false

  self:hide()
  if button == "left" then
    if selected then
      self:on_selected(selected)
      caught = true
    end
  end

  if button == "right" then
    caught = self:show(x, y)
  end
  return caught
end

-- copied from core.docview
function MenuContext:move_towards(t, k, dest, rate)
  if type(t) ~= "table" then
    return self:move_towards(self, t, k, dest, rate)
  end
  local val = t[k]
  if math.abs(val - dest) < 0.5 then
    t[k] = dest
  else
    t[k] = common.lerp(val, dest, rate or 0.5)
  end
  if val ~= dest then
    core.redraw = true
  end
end

function MenuContext:update()
  if self.show_context_menu then
    self:move_towards("height", self.items.height)
  end
end

function MenuContext:draw()
  if not self.show_context_menu then return end
  core.root_view:defer_draw(self.draw_context_menu, self)
end

function MenuContext:draw_context_menu()
  if not self.items then return end
  local bx, by, bw, bh = self.position.x, self.position.y, self.items.width, self.height
  
  renderer.draw_rect(
    bx - border_width,
    by - border_width,
    bw + (border_width * 2),
    bh + (border_width * 2),
    style.divider
  )
  renderer.draw_rect(bx, by, bw, bh, style.background3)
  
  for i, item, x, y, w, h in self:each_item() do
    if item == DIVIDER then
      renderer.draw_rect(x, y, w, h, style.caret)
    else
      if i == self.selected then
        renderer.draw_rect(x, y, w, h, style.selection)
      end

      common.draw_text(style.font, style.text, item.text, "left", x + style.padding.x, y, w, h)
      if item.info then
        common.draw_text(style.font, style.dim, item.info, "right", x, y, w - style.padding.x, h)
      end
    end
  end
end


local menucontext = MenuContext()
local root_view_on_mouse_pressed = RootView.on_mouse_pressed
local root_view_on_mouse_moved = RootView.on_mouse_moved
local root_view_update = RootView.update
local root_view_draw = RootView.draw

function RootView:on_mouse_moved(...)
  if menucontext:on_mouse_moved(...) then return end
  root_view_on_mouse_moved(self, ...)
end

-- copied from core.rootview
function RootView:on_mouse_pressed(button, x,y, clicks)
  local div = self.root_node:get_divider_overlapping_point(x, y)
  if div then
    self.dragged_divider = div
    return
  end
  local node = self.root_node:get_child_overlapping_point(x, y)
  local idx = node:get_tab_overlapping_point(x, y)
  if idx then
    node:set_active_view(node.views[idx])
    if button == "middle" then
      node:close_active_view(self.root_node)
    end
  else
    core.set_active_view(node.active_view)
    -- send to context menucontext first
    if not menucontext:on_mouse_pressed(button, x, y, clicks) then
      node.active_view:on_mouse_pressed(button, x, y, clicks)
    end
  end
end

function RootView:update(...)
  root_view_update(self, ...)
  menucontext:update()
end

function RootView:draw(...)
  root_view_draw(self, ...)
  menucontext:draw()
end

command.add(nil, {
  ["context:show"] = function()
    menucontext:show(core.active_view.position.x, core.active_view.position.y)
  end
})

keymap.add {
  ["menucontext"] = "context:show"
}

-- register some sensible defaults
menucontext:register("core.docview", {
  { text = "Cut", command = "doc:cut" },
  { text = "Copy", command = "doc:copy" },
  { text = "Paste", command = "doc:paste" },
  DIVIDER,
  { text = "Command Palette...", command = "core:find-command" }
})

return menucontext
