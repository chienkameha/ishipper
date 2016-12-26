class Shop::ShippersController < Shop::ShopBaseController

  def index
    @shippers = if params[:type]
      current_user.send params[:type]
    else
      current_user.list_shipper_received
    end
    @shippers = @shippers.search_user "Shipper", params[:name_shipper] if params[:name_shipper]
    @shippers = ActiveModelSerializers::SerializableResource.new @shippers,
      each_serializer: Users::ListShipperSerializer, scope: {invoice: nil,
      current_user: current_user}
    @current_type = params[:type].present? ? params[:type] : Settings.shipper.types.list_shipper_received
  end

  def update
    if params[:action_type] && current_user.send("#{params[:action_type]}", "#{params[:id]}")
      @shippers = current_user.send params[:current_type]
      @shippers = ActiveModelSerializers::SerializableResource.new @shippers,
        each_serializer: Users::ListShipperSerializer, scope: {invoice: nil,
        current_user: current_user}
      @current_type = params[:current_type]
    end
  end
end
