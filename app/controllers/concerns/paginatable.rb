module Paginatable
  extend ActiveSupport::Concern

  def render_paginated_collection(collection, blueprint, root:)
    paginated_collection = collection.page(params[:page]).per(params[:per_page])

    render json: blueprint.render(paginated_collection,
      root: root,
      meta: {
        current_page: paginated_collection.current_page,
        total_pages: paginated_collection.total_pages,
        total_count: paginated_collection.total_count
      })
  end
end
