class AnnouncementCard < Avo::Dashboards::PartialCard
  self.id = "Informationen"
  self.cols = 3
  self.rows = 1
  self.partial = "avo/cards/announcement_card"
  self.display_header = false

  self.visible = ->(args) { false }
end
