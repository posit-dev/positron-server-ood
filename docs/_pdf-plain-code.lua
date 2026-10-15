-- PDF only. Replaces highlighted code blocks with plain Verbatim blocks that
-- can break anywhere, so long URLs and paths wrap instead of running off the
-- page. Highlighting macros cannot break inside a string token.
function CodeBlock(el)
  -- The chapter's YAML header arrives as a code block; Quarto removes it later.
  if not quarto.doc.is_format("pdf") or el.classes:includes("quarto-title-block") then return nil end
  return pandoc.RawBlock("latex",
    "\\begin{Shaded}\n\\begin{Verbatim}[breaklines,breakanywhere,breaksymbolleft={},fontsize=\\small]\n"
    .. el.text .. "\n\\end{Verbatim}\n\\end{Shaded}")
end

-- Inline code becomes \texttt{}, which LaTeX cannot break, so long paths run
-- into the margin. Escape the text and allow a break after each separator.
local function tex_escape(s)
  s = s:gsub("\\", "\0")
  s = s:gsub("([{}$&#_%%])", "\\%1")
  s = s:gsub("%^", "\\^{}")
  s = s:gsub("~", "\\~{}")
  s = s:gsub("<", "\\textless{}")
  s = s:gsub(">", "\\textgreater{}")
  s = s:gsub("%z", "\\textbackslash{}")
  return s
end

function Code(el)
  if not quarto.doc.is_format("pdf") then return nil end
  local s = tex_escape(el.text)
  s = s:gsub("([/%.%-:])", "%1\\allowbreak{}")
  s = s:gsub("\\_", "\\_\\allowbreak{}")
  return pandoc.RawInline("latex", "\\texttt{" .. s .. "}")
end

-- Keep a heading with the text that follows it instead of leaving it alone at
-- the bottom of a page.
function Header(el)
  if not quarto.doc.is_format("pdf") or el.level < 2 then return nil end
  return { pandoc.RawBlock("latex", "\\needspace{6\\baselineskip}"), el }
end
