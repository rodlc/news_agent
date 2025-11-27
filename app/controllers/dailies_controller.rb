class DailiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_daily, only: [:show, :edit, :update, :destroy]

  def index
    @dailies = current_user.dailies.order(created_at: :desc)
  end

  def new
    # Pas besoin de formulaire, on redirige directement vers create
    redirect_to dailies_path, method: :post
  end

  def create
    @daily = Daily.new(
      title: "Résumé du #{Time.zone.now.strftime('%d/%m/%Y')}",
      summary: "",
      user: current_user
    )

    if @daily.save
      redirect_to edit_daily_path(@daily), notice: "Nouveau résumé créé ! Modifiez-le selon vos besoins."
    else
      redirect_to root_path, alert: "Erreur lors de la création du résumé"
    end
  end

  def show
  end

  def edit
  end

  def update
    if @daily.update(daily_params)
      redirect_to @daily, notice: "Résumé mis à jour"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @daily.destroy
    redirect_to dailies_path, notice: "Résumé supprimé"
  end

  private

  def set_daily
    @daily = Daily.find(params[:id])
    redirect_to root_path, alert: "Accès refusé" unless @daily.user == current_user
  end

  def daily_params
    params.require(:daily).permit(:summary, :title)
  end
end
