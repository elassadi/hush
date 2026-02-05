class CommentableTool < Avo::BaseResourceTool
  self.name = "CommentableTool"
  self.partial = "avo/commentable/commentable_turboframe"

  def visible?
    true
  end
end
