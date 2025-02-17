# frozen_string_literal: true

class Sites::VisualDesignsController < Sites::SetupSiteController
  def edit; end

  def update
    if @site.update(site_params)
      redirect_to edit_site_visual_design_path(@site),
                  flash: { success: 'You have updated your font & colors.' }
    else
      render :edit
    end
  end

  private

  def site_params
    params.require(:site).permit(
      visual_design_json: [
        :header_links_font_family,
        :footer_and_results_font_family
      ]
    )
  end
end
