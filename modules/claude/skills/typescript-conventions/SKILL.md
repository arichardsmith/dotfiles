---
name: typescript-patterns
description: Conventions for TypeScript types, interfaces, assertions, and type safety. Use when writing or reviewing TypeScript code.
---

# TypeScript Patterns Skill

Best practices for types, interfaces, assertions, and type safety.

## Use Explicit Return Types
```typescript
// ✅ Explicit return type
function calculateTotal(items: OrderItem[]): number {
    return items.reduce((sum, item) => sum + item.price, 0);
}

// ❌ Inferred return type
function calculateTotal(items: OrderItem[]) {
    return items.reduce((sum, item) => sum + item.price, 0);
}
```

**Why:** Explicit return types catch when we try to return incorrect data. They also speed up type checking.

## Runtime Type Assertions

Never hard cast from `JSON.parse`. Validate at runtime.
```typescript
// ❌ Hard cast
const value: MyType = JSON.parse(message);

// ✅ Runtime assertion
function isMyType(value: unknown): value is MyType {
    return typeof value === 'object' &&
        value !== null &&
        typeof (<MyType>value).prop === 'string';
}

const value = JSON.parse(message);
assert(isMyType(value), 'Invalid message format');
```

## Type Assertion Functions
```typescript
// Parameter: 'value' with 'unknown' type
// Always return boolean, never throw
function isStrategy(value: unknown): value is Strategy {
    return typeof value === 'object' &&
        value !== null &&
        typeof (<Strategy>value).name === 'string';
}

// Use with assert
assert(isStrategy(value), 'Value is not a valid Strategy');
```

## Interfaces vs Types
```typescript
// Interface for module-scope object types
export interface Product {
    id: string;
    name: string;
    price: number;
}

// Type when combining or modifying existing types

type StockedProduct = Exclude<Product, "name"> & { stock: StockStatus }


// Type for unions
type Status = 'pending' | 'active' | 'inactive';
```

## Casting Syntax
```typescript
// ✅ 'as' syntax
const x = y as number;

// ❌ Angle bracket syntax
const x = <number>y;
const config = <ConfigType>JSON.parse(json);
```

## Interface Conventions

- No `I` prefix or `Data` suffix
- Properties in alphabetical order
- Think of interfaces as nouns or adjectives (Shippable, Refundable)
```typescript
// Adjective interfaces
interface Shippable {
    shipping_address: string;
    shipping_cost: number;
}

// Concrete interface
interface Order extends Shippable {
    id: string;
    total: number;
}
```

## Enums

Never use typescript enums. Instead use objects with text values and infer the value type from the object.
```typescript
export const OrderStatus = {
    confirmed: "confirmed",
    paid: "paid",
    shipped: "shipped"
}

export type OrderStatus = (typeof OrderStatus)[keyof typeof OrderStatus];
```

## Type Shadowing

It is ok (infact prefered) to shadow enums and validation schemas with the resulting type. However, do not type shadow in other cases.

```typescript
// ✅ schema shadowing
export const Product = z.object({
    id: z.string(),
    name: z.string(),
    price: z.number().min(0)
})

export type Product = z.infer<typeof Product>;

// ❌ other shadowing
export const Config = {
    allow_net: true,
    units: "standard"
}

export type Config = {
    allow_next: false,
    units: Unit
}
````

## Iteration
```typescript
// ✅ for...of loop
for (const item of items) {
    processItem(item);
}

// ❌ forEach
items.forEach((item) => {
    processItem(item);
});
```

**Why:** `for...of` works with `break`, `continue`, `return`, `await`, and has better debugging/stack traces.

Use `map`/`filter`/`reduce` for transformations, not side effects.

## Import Style
```typescript
// ✅ Namespace imports
import * as mongodb from 'mongodb';
import * as Types from './types/index.js';

// ❌ Default imports
import MongoDB from 'mongodb';
```

## Organization

- Keep types with related code (not in `types/` directories)
- Only export types that are part of public API
- Use `ReturnType` and `Parameters` to access private types
