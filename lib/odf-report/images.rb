module ODFReport

  module Images

    IMAGE_DIR_NAME = "Pictures"

    def update_images(file)

      return if @images.empty?

      @image_name_additions.each_pair do |local_file, old_file|

        new_file = ::File.join(IMAGE_DIR_NAME, ::File.basename(local_file))

        file.output_stream.put_next_entry(new_file)
        file.output_stream.write ::File.read(local_file)

      end
    end

    def update_manifest(content)

      return unless root_node = content.xpath("//manifest:manifest").first

      @global_image_paths_set.each do |path|

        next if root_node.xpath(".//manifest:file-entry[@manifest:full-path='#{path}']").first

        if mime_type = mime_type_for(path)
          node = content.create_element('manifest:file-entry')
          node['manifest:media-type'] = mime_type
          node['manifest:full-path'] = path

          root_node.add_child node
        end

      end

    end

    def mime_type_for(tmp_path)
      case ::File.extname(tmp_path)
      when ".png"
        "image/png"
      when ".gif"
        "image/gif"
      when ".jpeg", ".jpg"
        "image/jpeg"
      end
    end

    # newer versions of LibreOffice can't open files with duplicates image names
    def avoid_duplicate_image_names(content)

      nodes = content.xpath("//draw:frame[@draw:name]")

      nodes.each_with_index do |node, i|
        node.attribute('name').value = "pic_#{i}"
        node.xpath(".//draw:image").each do |draw_image|
          href =  draw_image.attribute('href').value
          unless href.to_s.empty?
            @global_image_paths_set.add(href)
          end
        end
      end
    end

  end

end
