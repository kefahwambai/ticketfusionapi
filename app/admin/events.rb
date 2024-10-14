ActiveAdmin.register Event do
  permit_params :name, :description, :date, :location, :start_time, :image

  form do |f|
    f.inputs do
      f.input :name
      f.input :description
      f.input :date, as: :datetime_picker
      f.input :location
      f.input :start_time, as: :time_select
      f.input :image, as: :file
    end
    f.actions
  end
end
