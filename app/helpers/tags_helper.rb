module TagsHelper
  def get_tags_table_info
    tags = Tag.all(order: 'name')

    tags.map do |tag|
      t = tag.attributes
      t[:user_name] = User.find(tag.user).first_name +
                      ' ' + User.find(tag.user).last_name
      t[:use] = get_num_groupings_for_tag(tag.id)
      t[:edit_link] = view_context.link_to(
          'Edit',
          edit_tag_dialog_assignment_tag_path(@assignment, tag),
          remote: true)
      t[:delete_link] = view_context.link_to(
          'Delete',
          controller: 'tags',
          action: 'destroy',
          data: { confirm: 'Are you sure you want to delete this tag?' },
          id: tag.id)
      t
    end
  end

  ###  Update methods  ###

  def update_name
    Tag.update(params[:id], name: params[:name])
  end

  def update_description
    Tag.update(params[:id], description: params[:description])
  end

  ###  Grouping Methods ###

  def create_grouping_tag_association_from_existing_tag(grouping_id, tag_id)
    tag = Tag.find(tag_id)
    create_grouping_tag_association(grouping_id, tag)
  end

  def create_grouping_tag_association(grouping_id, tag)
    if !tag.groupings.exists?(grouping_id)
      grouping = Grouping.find(grouping_id)
      tag.groupings << (grouping)
    end
  end

  def get_tags_for_grouping(grouping_id)
    grouping = Grouping.find(grouping_id)
    grouping.tags
  end

  def get_num_groupings_for_tag(tag_id)
    tag = Tag.find(tag_id)
    count = 0

    Grouping.all.each do |group|
      if tag.groupings.exists?(group.id)
        count += 1
      end
    end

    count
  end

  def get_tags_not_associated_with_grouping(g_id)
    grouping = Grouping.find(g_id)
    grouping_tags = grouping.tags

    all_tags = Tag.all
    all_tags.delete_if do |t|
      grouping_tags.include?(t)
    end

    all_tags
  end

  def delete_grouping_tag_association(tag_id, grouping_id)
    tag = Tag.find(tag_id)
    tag.groupings.delete(grouping_id)
  end
end
