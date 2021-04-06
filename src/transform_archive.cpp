/* Copyright (C) 2020 G'k
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

#include "transform_archive.hpp"
#include "bsa_saver.hpp"
#include "utils/scope_fail.hpp"

namespace libbsarch {

void transform_archive(const bsa &source,
                       const fs::path &target_path,
                       const transform_callback &callback,
                       bsa_archive_type_t type)
{
    const auto &files = source.list_files();

    bsa_entry_list entries;
    std::for_each(files.cbegin(), files.cend(), [&entries](auto &&file) { entries.add(file); });

    if (type == baNone)
        type = source.get_type();

    bsa target;
    target.set_archive_flags(source.get_archive_flags());
    target.set_file_flags(source.get_file_flags());
    target.set_compressed(source.get_compressed());
    target.set_share_data(source.get_share_data());

    bsa_saver_complex target_saver(std::move(target));

    target_saver.prepare(target_path, std::move(entries), type);
    scope_fail guard([target_path] { fs::remove(target_path); });

    auto context = std::make_tuple(&source, &callback, &target_saver);
    using context_type = decltype(context);

    target_saver.get_bsa().iterate_files(
        [](auto, const wchar_t *file_path, auto, auto, void *context) {
            auto [source, callback, target_saver] = *static_cast<context_type *>(context);
            const fs::path relative_path(file_path);
            extracted_data input_blob = source->extract_to_memory(relative_path);
            auto output = (*callback)(relative_path, std::move(input_blob));
            target_saver->add_file(relative_path, std::move(output));
            return false;
        },
        &context);

    target_saver.save();
}

} // namespace libbsarch
