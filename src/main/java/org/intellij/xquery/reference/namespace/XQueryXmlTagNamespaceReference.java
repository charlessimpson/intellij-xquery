/*
 * Copyright 2013-2014 Grzegorz Ligas <ligasgr@gmail.com> and other contributors
 * (see the CONTRIBUTORS file).
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.intellij.xquery.reference.namespace;

import com.intellij.openapi.util.TextRange;
import com.intellij.psi.PsiElement;
import com.intellij.psi.PsiElementResolveResult;
import com.intellij.psi.PsiPolyVariantReference;
import com.intellij.psi.PsiReferenceBase;
import com.intellij.psi.ResolveResult;
import com.intellij.util.IncorrectOperationException;
import org.intellij.xquery.psi.XQueryElementFactory;
import org.intellij.xquery.psi.XQueryFile;
import org.intellij.xquery.psi.XQueryFunctionName;
import org.intellij.xquery.psi.XQueryModuleImport;
import org.intellij.xquery.psi.XQueryNamespaceDecl;
import org.intellij.xquery.psi.XQueryNamespacePrefix;
import org.intellij.xquery.psi.XQueryPrefix;
import org.intellij.xquery.psi.XQueryXmlEmptyTag;
import org.intellij.xquery.psi.XQueryXmlTagNamespace;
import org.intellij.xquery.reference.namespace.XQueryPredeclaredNamespace;
import org.intellij.xquery.reference.namespace.XQueryPrefixReference;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.List;

import static java.util.Collections.emptyList;

public class XQueryXmlTagNamespaceReference extends XQueryPrefixReference<XQueryXmlTagNamespace> {
    public XQueryXmlTagNamespaceReference(XQueryXmlTagNamespace element, TextRange textRange) {
        super(element, textRange);
    }

    @Override
    protected Collection<? extends ResolveResult> getAdditionalReferences() {
        return Collections.emptyList();
    }

    @Override
    public PsiElement handleElementRename(String newElementName) throws IncorrectOperationException {
        myElement.replace(getUpdatedRef(newElementName).getXmlTagName().getXmlTagNamespace());
        return myElement;
    }

    private XQueryXmlEmptyTag getUpdatedRef(String newName) {
        XQueryXmlEmptyTag xmlTag = XQueryElementFactory.createXmlTag(myElement.getProject(),
                newName, "dummy");
        return xmlTag;
    }


}
