module ApplicationHelper
  def ApplicationHelper.email_regex
    /\A.+@[a-z\d\-.]+\.[a-z]+\z/i
  end

  def link_to_add_fields(name, f, association, options = {})
    layout_dir = (options.key?( :layout_dir ) ? options[:layout_dir] : 'shared')
    partial_name = (options.key?( :partial_name ) ? options[:partial_name] : (association.to_s.singularize + '_fields'))
    insert_element_string = (options.key?( :insert_element ) ? "\"#{options[:insert_element]}\"" : 'null' )
    new_object = (options.key?( :new_object ) ? options[:new_object] : f.object.class.reflect_on_association(association).klass.new )

    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render( layout_dir + '/' + partial_name, :f => builder )
    end

    link_options = { :onclick => "return add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\", #{insert_element_string});" }
    if options[:link_options]
      link_options.merge!( options[:link_options] )
    end
    link_to( name, '#', link_options )
  end

  def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy, :class => "fields-remove") + link_to(name, '#', :onclick => "return remove_fields(this)", :class => 'fields-remove-link')
  end
end
