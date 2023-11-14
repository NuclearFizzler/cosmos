# Copyright 2023 OpenC3, Inc.
# All Rights Reserved.
#
# This program is free software; you can modify and/or redistribute it
# under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation; version 3 with
# attribution addendums as found in the LICENSE.txt
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# This file may also be used under the terms of a commercial license
# if purchased from OpenC3, Inc.

from openc3.accessors.xml_accessor import XmlAccessor
import lxml.html as HTML


class HtmlAccessor(XmlAccessor):
    @classmethod
    def buffer_to_doc(cls, buffer):
        return HTML.fromstring(buffer)

    @classmethod
    def doc_to_buffer(cls, doc):
        return HTML.tostring(doc)