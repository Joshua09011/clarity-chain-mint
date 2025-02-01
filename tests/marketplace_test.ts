import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensure can list and purchase asset",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const buyer = accounts.get('wallet_1')!;
    
    // Create asset first
    let block = chain.mineBlock([
      Tx.contractCall('marketplace', 'list-asset',
        [types.uint(1), types.uint(1000)],
        deployer.address
      ),
      Tx.contractCall('marketplace', 'purchase-asset',
        [types.uint(1)],
        buyer.address
      )
    ]);

    assertEquals(block.receipts[1].result.expectOk(), true);
  },
});
