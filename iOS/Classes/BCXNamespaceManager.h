//
//  BCNamespaceManager.h
//  Securely
//
//  Created by Ben on 4/17/13.
//
//

#ifndef __BCX_NAMESPACE_PREFIX_
#define __BCX_NAMESPACE_PREFIX_	BCX
#endif

#ifndef __BCX_NS_SYMBOL
// Must have multiple levels of macros so that __BCX_NAMESPACE_PREFIX_ is
// properly replaced by the time the namespace prefix is concatenated.
#define __BCX_NS_REWRITE(ns, symbol) ns ## _ ## symbol
#define __BCX_NS_BRIDGE(ns, symbol) __BCX_NS_REWRITE(ns, symbol)
#define __BCX_NS_SYMBOL(symbol) __BCX_NS_BRIDGE(__BCX_NAMESPACE_PREFIX_, symbol)
#endif

#ifndef RNCryptManager
#define RNCryptManager __BCX_NS_SYMBOL(RNCryptManager)
#endif

