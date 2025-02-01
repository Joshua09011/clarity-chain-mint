import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensure can create new asset",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const wallet1 = accounts.get('wallet_1')!;

    let block = chain.mineBlock([
      Tx.contractCall('asset-registry', 'create-asset', 
        [types.utf8("Test Asset"), types.principal(wallet1.address)],
        deployer.address
      )
    ]);
    
    assertEquals(block.receipts[0].result.expectOk(), '1');
  },
});

Clarinet.test({
  name: "Ensure only owner can create assets",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet1 = accounts.get('wallet_1')!;

    let block = chain.mineBlock([
      Tx.contractCall('asset-registry', 'create-asset',
        [types.utf8("Test Asset"), types.principal(wallet1.address)],
        wallet1.address
      )
    ]);
    
    assertEquals(block.receipts[0].result.expectErr(), '100');
  },
});
