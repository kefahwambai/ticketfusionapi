ActiveAdmin.register User do
  permit_params :business_name, :phone_number, :name, :email, :password

  form do |f|
    f.inputs do
      f.input :business_name
      f.input :phone_number
      f.input :name
      f.input :email
      f.input :password
    end
    f.actions
  end

  # Customizing the filters to exclude password_digest
  filter :business_name
  filter :phone_number
  filter :name
  filter :email
end
